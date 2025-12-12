import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/controllers/history_controller.dart'; // Import HistoryController
import 'package:graduation_project_depi/services/budget_service.dart'; // Import Service
import 'package:graduation_project_depi/user_session.dart';

class BudgetController extends GetxController {
  final _budgetService = BudgetService(); // Initialize Service

  // Observables
  final monthlyLimit = 0.obs;
  final isOverBudget = false.obs;
  final usagePercentage = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBudgetFromSession();

    if (Get.isRegistered<HistoryController>()) {
      final historyCtrl = Get.find<HistoryController>();
      ever(historyCtrl.historyItems, (_) {
        checkBudgetStatus(0); // Re-check with 0 pending bill
      });
    }
  }

  void _loadBudgetFromSession() {
    final user = UserSession().currentUser;
    if (user != null && user.budgetLimit != null) {
      monthlyLimit.value = user.budgetLimit!;
    }
  }

  // Save new limit using BudgetService
  Future<void> setLimit(String value) async {
    if (value.isEmpty) return;
    int limit = int.tryParse(value) ?? 0;

    // 1. Update UI immediately
    monthlyLimit.value = limit;

    // 2. Update Session
    UserSession().currentUser?.budgetLimit = limit;

    // 3. Re-check status immediately with new limit
    checkBudgetStatus(0);

    // 4. Save to Database via Service
    await _budgetService.updateBudgetLimit(limit);
  }

  void checkBudgetStatus(double newBillAmount) {
    if (monthlyLimit.value <= 0) {
      isOverBudget.value = false;
      return;
    }

    double existingTotal = 0.0;

    // Use HistoryController data instead of fetching DB again
    if (Get.isRegistered<HistoryController>()) {
      final historyCtrl = Get.find<HistoryController>();
      final now = DateTime.now();

      // Filter items for the current month
      final currentMonthItems = historyCtrl.historyItems.where((item) {
        return item.date.year == now.year && item.date.month == now.month;
      });

      existingTotal = currentMonthItems.fold(
        0.0,
        (sum, item) => sum + item.cost,
      );
    }

    // Add the NEW bill (calculated but not yet saved)
    double totalProjected = existingTotal + newBillAmount;

    usagePercentage.value = (totalProjected / monthlyLimit.value).clamp(
      0.0,
      1.0,
    );

    // Compare & Alert
    if (totalProjected > monthlyLimit.value) {
      isOverBudget.value = true;

      if (newBillAmount > 0) {
        Get.snackbar(
          'Budget Alert!',
          'You have exceeded your monthly limit! Total: ${totalProjected.toStringAsFixed(2)} EGP',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.warning, color: Colors.white),
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
        );
      }
    } else if (totalProjected > (monthlyLimit.value * 0.9)) {
      isOverBudget.value = false;
      if (newBillAmount > 0) {
        Get.snackbar(
          'Warning',
          'You are at ${(usagePercentage.value * 100).toStringAsFixed(0)}% of your monthly budget.',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
        );
      }
    } else {
      isOverBudget.value = false;
    }
  }
}
