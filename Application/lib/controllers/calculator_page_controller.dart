import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:graduation_project_depi/controllers/analytics_page_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project_depi/entities/reading.dart';
import 'package:graduation_project_depi/services/electricity_reading_service.dart';
import 'package:speech_to_text/speech_to_text.dart'
    as stt; // Import Speech To Text
import 'package:supabase_flutter/supabase_flutter.dart';

import 'history_controller.dart';
import 'budget_controller.dart';

class CalculatorPageController extends GetxController {
  final _readingService = Get.find<ElectricityReadingService>();
  final _supabase = Get.find<SupabaseClient>();

  final currentReadingController = TextEditingController();

  final cost = ''.obs;
  final consumption = ''.obs;
  final isLoading = false.obs;
  final lastDbReading = Rxn<int>();

  final picker = ImagePicker();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final isListening = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLastReading();
  }

  void fetchLastReading() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      final reading = await _readingService.getLatestReading(userId);
      if (reading != null) {
        lastDbReading.value = reading.meterValue;
      } else {
        lastDbReading.value = 0;
      }
    }
  }

  double calculateElectricity(int current, int previous) {
    final reading = current - previous;
    double rate;
    double serviceFee;

    if (reading <= 50) {
      rate = 0.58;
      serviceFee = 2;
    } else if (reading <= 100) {
      rate = 0.68;
      serviceFee = 4;
    } else if (reading <= 200) {
      rate = 0.83;
      serviceFee = 6;
    } else if (reading <= 350) {
      rate = 1.00;
      serviceFee = 8;
    } else if (reading <= 650) {
      rate = 1.18;
      serviceFee = 10;
    } else if (reading <= 1000) {
      rate = 1.28;
      serviceFee = 12;
    } else {
      rate = 1.45;
      serviceFee = 15;
    }

    return (reading * rate) + serviceFee;
  }

  bool validateInputs() {
    if (currentReadingController.text.isEmpty) {
      Get.snackbar('Missing Data'.tr, 'Please enter the current reading!'.tr);
      return false;
    }
    final current = int.tryParse(currentReadingController.text);
    final previous = lastDbReading.value ?? 0;

    if (current == null) {
      Get.snackbar('Invalid Input'.tr, 'Please enter a valid number!'.tr);
      return false;
    }
    if (current < previous) {
      Get.snackbar(
        'Error'.tr,
        'Current reading cannot be less than previous reading!'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  Future<void> calculate() async {
    if (!validateInputs()) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      Get.snackbar(
        'Error'.tr,
        'User not logged in.'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final current = int.parse(currentReadingController.text);
    final previous = lastDbReading.value ?? 0;

    final consum = current - previous;
    final totalCost = calculateElectricity(current, previous);
    cost.value = 'Total Bill: %s EGP'.trArgs([totalCost.toStringAsFixed(2)]);
    consumption.value = 'Consumption: %s kWh'.trArgs([consum.toStringAsFixed(0)]);
    if (Get.isRegistered<BudgetController>()) {
      Get.find<BudgetController>().checkBudgetStatus(totalCost);
    }

    final newReading = Reading(
      userId: userId,
      meterValue: current,
      cost: totalCost,
      createdAt: DateTime.now(),
    );

    bool success = await _readingService.insertReading(newReading);

    if (success) {
      Get.snackbar(
        'Success'.tr,
        'Saved successfully!'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().addLocalReading(newReading, consum);
      }

      final double kwhDouble = consum.toDouble();
      final DateTime timestamp = newReading.createdAt ?? DateTime.now();
      try {
        if (Get.isRegistered<AnalyticsController>()) {
          Get.find<AnalyticsController>().updateFromConsumption(
            kwhDouble,
            totalCost,
            timestamp,
          );
        }
      } catch (e) {
        debugPrint('Analytics error: $e');
      }

      lastDbReading.value = current;
      currentReadingController.clear();
    } else {
      Get.snackbar(
        'Error'.tr,
        'Failed to save.'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

  Future<void> startVoiceInput() async {
    if (!isListening.value) {
      bool available = await _speech.initialize(
        onError: (val) {
          print('onError: $val');
          isListening.value = false;
        },
        onStatus: (val) {
          print('onStatus: $val');
          if (val == 'done' || val == 'notListening') {
            isListening.value = false;
          }
        },
      );

      if (available) {
        isListening.value = true;
        _speech.listen(
          onResult: (result) {
            String recognizedWords = result.recognizedWords;
            final numbers = RegExp(
              r'\d+',
            ).allMatches(recognizedWords).map((m) => m.group(0)).join("");

            if (numbers.isNotEmpty) {
              currentReadingController.text = numbers;
            }
          },
          localeId: 'ar_EG',
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          "Error",
          "Speech recognition not available",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      isListening.value = false;
      _speech.stop();
    }
  }

  // --- Image OCR Logic ---
  Future<void> scanForField(
    TextEditingController target,
    BuildContext context,
  ) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.camera_alt, color: Color(0xFF1565C0)),
                ),
                title: Text(
                  "Take Photo".tr,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Get.back();
                  await runOCR(target, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.photo_library, color: Color(0xFF1565C0)),
                ),
                title: Text(
                  "Choose from Gallery".tr,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Get.back();
                  await runOCR(target, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> runOCR(TextEditingController target, ImageSource source) async {
    try {
      final picked = await picker.pickImage(source: source);
      if (picked == null) return;
      isLoading.value = true;
      final inputImage = InputImage.fromFile(File(picked.path));
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await recognizer.processImage(inputImage);
      List<int> numbers = [];
      for (var block in result.blocks) {
        for (var line in block.lines) {
          for (var m in RegExp(r'\d+').allMatches(line.text)) {
            numbers.add(int.parse(m.group(0)!));
          }
        }
      }
      await recognizer.close();
      isLoading.value = false;
      if (numbers.isEmpty) {
        Get.snackbar(
          "Error",
          "No numbers found in image!",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      numbers.sort();
      target.text = numbers.last.toString();
      Get.snackbar(
        "Done",
        "Number extracted: ${numbers.last}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Failed to scan image: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
