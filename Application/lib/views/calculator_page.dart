import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/controllers/calculator_page_controller.dart';

class CalculatorPage extends GetView<CalculatorPageController> {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        title: const Text(
          "Meter Reading",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Electricity "Tab" Indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Electricity",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Hidden "Gas" placeholder to make "Electricity" look like a tab
                    const Expanded(
                      child: Center(
                        child: Text(
                          "", // Empty as requested
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2. Loading Indicator
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: SpinKitThreeBounce(
                        color: Color(0xFF1565C0),
                        size: 30,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // 3. Previous Reading (Read-Only Field)
              const Text(
                "Previous Reading",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => TextField(
                  controller: TextEditingController(
                    text: controller.lastDbReading.value?.toString() ?? '0',
                  ),
                  enabled: false, // Read-only
                  style: const TextStyle(color: Colors.grey),
                  decoration: InputDecoration(
                    hintText: "Fetching...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 4. Current Reading (Active Field)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Current Reading",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(Icons.info_outline, size: 18, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.currentReadingController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter today's reading",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 5. Action Buttons (Voice & Camera)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Placeholder for voice feature
                        Get.snackbar(
                          "Coming Soon",
                          "Voice input is not yet implemented.",
                        );
                      },
                      icon: const Icon(Icons.mic, color: Colors.black54),
                      label: const Text(
                        "Input with Voice",
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.scanForField(
                        controller.currentReadingController,
                        context,
                      ),
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.black54,
                      ),
                      label: const Text(
                        "Scan with Camera",
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 6. Calculate Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.calculate(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF1565C0,
                    ), // Blue color from image button
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Calculate Consumption",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 7. Results Display (Clean Text)
              Center(
                child: Obx(() {
                  if (controller.cost.value.isEmpty)
                    return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          controller.cost.value,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.consumption.value,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
