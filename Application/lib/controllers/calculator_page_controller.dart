import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class CalculatorPageController extends GetxController {
  final previousReadingController = TextEditingController();
  final currentReadingController = TextEditingController();
  final cost = ''.obs;
  final consumption = ''.obs;

  final isLoading = false.obs;

  final picker = ImagePicker();

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
    if (previousReadingController.text.isEmpty ||
        currentReadingController.text.isEmpty) {
      Get.snackbar(
        'Missing Data',
        'Please fill in both readings!',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final previous = int.tryParse(previousReadingController.text);
    final current = int.tryParse(currentReadingController.text);

    if (previous == null || current == null) {
      Get.snackbar(
        'Invalid Input',
        'Please enter valid numbers!',
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      currentReadingController.clear();
      previousReadingController.clear();
      return false;
    }

    if (current < previous) {
      Get.snackbar(
        'Error',
        'Current reading cannot be less than previous reading!',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      currentReadingController.clear();
      previousReadingController.clear();
      return false;
    }

    return true;
  }

  void calculate() {
    if (!validateInputs()) return;

    final previous = int.parse(previousReadingController.text);
    final current = int.parse(currentReadingController.text);
    final consum = current - previous;
    final total = calculateElectricity(current, previous);
    cost.value = 'Your Total Bill: ${total.toStringAsFixed(2)} EGP';
    consumption.value = 'Your consumption: ${consum.toStringAsFixed(0)} kWh';

    Get.snackbar(
      'Success',
      'Electricity bill calculated successfully!',
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    currentReadingController.clear();
    previousReadingController.clear();
  }

  Future<void> scanForField(
    TextEditingController target,
    BuildContext context,
  ) async {
    showModalBottomSheet(
      context: context,
      elevation: 10,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  await runOCR(target, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await runOCR(target, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> runOCR(TextEditingController target, ImageSource source) async {
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
      Get.snackbar("Error", "No numbers found in image!");
      return;
    }

    numbers.sort();
    target.text = numbers.last.toString(); // Take largest reading

    Get.snackbar("Done", "Number extracted successfully!");
  }
}
