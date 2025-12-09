import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/controllers/calculator_page_controller.dart';
import 'package:graduation_project_depi/controllers/budget_controller.dart';

class CalculatorPage extends GetView<CalculatorPageController> {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access budget controller to show UI updates
    final budgetController = Get.find<BudgetController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
              // 1. Utility Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.electric_bolt_rounded,
                        color: Color(0xFF1565C0),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Electricity",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 2. Budget Goal Card (New)
              Obx(() {
                final budget = budgetController.monthlyLimit.value;
                final isSet = budget > 0;
                final isOver = budgetController.isOverBudget.value;

                return GestureDetector(
                  onTap: () =>
                      Get.toNamed('/budget'), // Navigate to budget screen
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: isOver ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOver
                            ? Colors.red.shade200
                            : Colors.green.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.savings_outlined,
                              color: isOver ? Colors.red : Colors.green[700],
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Monthly Limit",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isSet
                                      ? "${budget.toStringAsFixed(0)} EGP"
                                      : "Tap to set limit",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isOver ? Colors.red : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 30),

              // 3. Loading
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

              // 4. Previous Reading
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
                  enabled: false,
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
                    prefixIcon: Icon(Icons.history, color: Colors.grey[400]),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 5. Current Reading
              const Text(
                "Current Reading",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
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
                  prefixIcon: const Icon(Icons.speed, color: Color(0xFF1565C0)),
                ),
              ),

              const SizedBox(height: 25),

              // 6. Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.snackbar(
                        "Coming Soon",
                        "Voice input is not yet implemented.",
                      ),
                      icon: const Icon(Icons.mic, color: Colors.black54),
                      label: const Text(
                        "Voice Input",
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
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
                        "Scan Meter",
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 7. Calculate
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.calculate(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF1565C0).withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Calculate Consumption",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 8. Result
              Center(
                child: Obx(() {
                  if (controller.cost.value.isEmpty)
                    return const SizedBox.shrink();
                  final isOver = budgetController.isOverBudget.value;

                  return Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isOver ? Colors.red.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isOver
                            ? Colors.red.shade200
                            : Colors.blue.shade50,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isOver
                              ? Colors.red.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          isOver ? "Limit Exceeded!" : "Estimated Bill",
                          style: TextStyle(
                            fontSize: 14,
                            color: isOver ? Colors.red : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.cost.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isOver
                                ? Colors.red
                                : const Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isOver ? Colors.white : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            controller.consumption.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isOver ? Colors.red : Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
