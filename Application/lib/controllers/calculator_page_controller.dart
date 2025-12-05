import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:graduation_project_depi/controllers/analytics_page_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project_depi/entities/reading.dart';
import 'package:graduation_project_depi/services/electricity_reading_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'history_controller.dart';

class CalculatorPageController extends GetxController {
  // Services
  final _readingService = Get.find<ElectricityReadingService>();
  final _supabase = Get.find<SupabaseClient>();

  // UI Controllers
  final currentReadingController = TextEditingController();

  // Observables
  final cost = ''.obs;
  final consumption = ''.obs;
  final isLoading = false.obs;
  final lastDbReading = Rxn<int>();

  final picker = ImagePicker();

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
      Get.snackbar('Missing Data', 'Please enter the current reading!');
      return false;
    }

    final current = int.tryParse(currentReadingController.text);
    final previous = lastDbReading.value ?? 0;

    if (current == null) {
      Get.snackbar('Invalid Input', 'Please enter a valid number!');
      return false;
    }

    if (current < previous) {
      Get.snackbar(
        'Error',
        'Current reading ($current) cannot be less than previous reading ($previous)!',
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
        'Error',
        'User not logged in.',
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

    cost.value = 'Total Bill: ${totalCost.toStringAsFixed(2)} EGP';
    consumption.value = 'Consumption: ${consum.toStringAsFixed(0)} kWh';

    final newReading = Reading(
      userId: userId,
      meterValue: current,
      cost: totalCost,
      sourceType: SourceType.manual,
      createdAt: DateTime.now(), // Ensure we have a date for local update
    );

    bool success = await _readingService.insertReading(newReading);

    if (success) {
      Get.snackbar(
        'Success',
        'Saved successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().addLocalReading(newReading, consum);
      }
            final double kwhDouble = consum.toDouble();
        final DateTime timestamp = newReading.createdAt ?? DateTime.now();
        try {
          final analytics = Get.find<AnalyticsController>();
          analytics.updateFromConsumption(kwhDouble, totalCost, timestamp);
        } catch (e) {
          debugPrint('AnalyticsController not available: $e');
        }

      lastDbReading.value = current;
      currentReadingController.clear();
    } else {
      Get.snackbar(
        'Error',
        'Failed to save.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

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
                title: const Text(
                  "Take Photo",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await runOCR(target, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.photo_library, color: Color(0xFF1565C0)),
                ),
                title: const Text(
                  "Choose from Gallery",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(context);
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
          // Improved Regex to catch distinct numbers better
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
      // Assuming the meter reading is often the largest number on the display
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
