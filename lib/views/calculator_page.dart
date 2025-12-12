import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/controllers/calculator_page_controller.dart';
import 'package:graduation_project_depi/controllers/budget_controller.dart';

class CalculatorPage extends GetView<CalculatorPageController> {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetController = Get.find<BudgetController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Meter Reading",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
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
                    Text(
                      "Electricity",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 2. Budget Goal Card
              Obx(() {
                final budget = budgetController.monthlyLimit.value;
                final isSet = budget > 0;
                final isOver = budgetController.isOverBudget.value;
                final isDark = Theme.of(context).brightness == Brightness.dark;

                return GestureDetector(
                  onTap: () => Get.toNamed('/budget'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: isOver
                          ? (isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50)
                          : (isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOver
                            ? (isDark ? Colors.red.shade700 : Colors.red.shade200)
                            : (isDark ? Colors.green.shade700 : Colors.green.shade200),
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
                                    color: Theme.of(context).textTheme.bodySmall?.color,
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
                                    color: isOver
                                        ? Colors.red
                                        : Theme.of(context).textTheme.titleLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
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
              Text(
                "Previous Reading",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => TextField(
                  controller: TextEditingController(
                    text: controller.lastDbReading.value?.toString() ?? '0',
                  ),
                  enabled: false,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: "Fetching...",
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).cardColor
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.history,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 5. Current Reading
              Text(
                "Current Reading",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.currentReadingController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter today's reading",
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]!
                          : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.speed,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 6. Buttons (Voice & Scan)
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => ElevatedButton.icon(
                        onPressed: () => controller.startVoiceInput(),
                        icon: Icon(
                          controller.isListening.value
                              ? Icons.mic_off
                              : Icons.mic,
                          color: controller.isListening.value
                              ? Colors.red
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        label: Text(
                          controller.isListening.value
                              ? "Stop Listening"
                              : "Voice Input",
                          style: TextStyle(
                            color: controller.isListening.value
                                ? Colors.red
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                            ),
                          ),
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
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      label: Text(
                        "Scan Meter",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]!
                                : Colors.grey[300]!,
                          ),
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
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
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

                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isOver
                          ? (isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isOver
                            ? (isDark ? Colors.red.shade700 : Colors.red.shade200)
                            : (isDark ? Colors.blue.shade800 : Colors.blue.shade50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isOver
                              ? Colors.red.withOpacity(isDark ? 0.3 : 0.1)
                              : Colors.blue.withOpacity(isDark ? 0.2 : 0.08),
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
                            color: isOver
                                ? Colors.red
                                : Theme.of(context).textTheme.bodySmall?.color,
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
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isOver
                                ? (isDark ? Theme.of(context).cardColor : Colors.white)
                                : (isDark ? Colors.blue.shade900.withOpacity(0.5) : Colors.blue.shade50),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            controller.consumption.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isOver
                                  ? Colors.red
                                  : (isDark ? Colors.blue.shade300 : Colors.blue[800]),
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
