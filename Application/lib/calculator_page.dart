import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalculatorPage extends StatelessWidget {
  CalculatorPage({super.key});

  final previousReadingController = TextEditingController();
  final currentReadingController = TextEditingController();
  final cost = ''.obs;
  final consumption = ''.obs;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 20,
                  children: [
                    const Text(
                      ' Electricity Bill Calculator ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    TextField(
                      controller: previousReadingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.electric_bolt),
                        labelText: 'Previous Reading',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    TextField(
                      controller: currentReadingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.energy_savings_leaf),
                        labelText: 'Current Reading',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (!validateInputs()) return;

                        final previous = int.parse(
                          previousReadingController.text,
                        );
                        final current = int.parse(
                          currentReadingController.text,
                        );
                        final consum = current - previous;
                        final total = calculateElectricity(current, previous);
                        cost.value =
                            'Your Total Bill: ${total.toStringAsFixed(2)} EGP';
                        consumption.value =
                            'Your consumption: ${consum.toStringAsFixed(0)} kWh';

                        Get.snackbar(
                          'Success',
                          'Electricity bill calculated successfully!',
                          backgroundColor: Colors.green.shade400,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        currentReadingController.clear();
                        previousReadingController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                      ),
                      child: const Text(
                        'Calculate',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Obx(() {
                      return Text(
                        cost.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      );
                    }),
                    Obx(() {
                      return Text(
                        consumption.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
