import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/services/electricity_reading_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/history_item.dart';
import '../entities/reading.dart';
import 'calculator_page_controller.dart';

class HistoryController extends GetxController {
  final _readingService = Get.find<ElectricityReadingService>();
  final _supabase = Get.find<SupabaseClient>();

  // Stores all loaded data
  final List<HistoryItem> _allItems = [];

  // Stores currently visible data
  final historyItems = <HistoryItem>[].obs;

  final isLoading = true.obs;

  // Interactive State
  final selectedTab = 'Month'.obs; // Options: 'Month', 'Year'
  final isNewestFirst = true.obs;
  final selectedDateRange = Rxn<DateTimeRange>();

  // Dashboard Metrics (Reactive)
  final totalConsumption = 0.obs;
  final totalCost = RxDouble(0);

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  // 1. Fetch Data Once
  Future<void> fetchHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    final readings = await _readingService.getUserReadings(userId);

    // Sort to calculate differences correctly (Newest first)
    readings.sort(
      (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
        a.createdAt ?? DateTime.now(),
      ),
    );

    _allItems.clear();
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    for (int i = 0; i < readings.length; i++) {
      int consumption = 0;

      if (i + 1 < readings.length) {
        consumption = readings[i].meterValue - readings[i + 1].meterValue;
      } else {
        consumption = 0; // First reading
      }

      if (consumption < 0) consumption = 0;

      final date = readings[i].createdAt ?? DateTime.now();
      final formattedDate =
          "${monthNames[date.month - 1]} ${date.day}, ${date.year}";

      _allItems.add(
        HistoryItem(
          consumption: consumption,
          cost: readings[i].cost ?? 0,
          date: date,
          dateRange: formattedDate,
        ),
      );
    }

    // Apply default filters
    applyFilters();
    isLoading.value = false;
  }

  // 2. Filter Logic
  void applyFilters() {
    List<HistoryItem> temp = List.from(_allItems);
    final now = DateTime.now();

    // A. Filter by Tab (Month/Year)
    if (selectedDateRange.value != null) {
      // If custom date range is selected, ignore tabs
      temp = temp
          .where(
            (i) =>
                i.date.isAfter(selectedDateRange.value!.start) &&
                i.date.isBefore(
                  selectedDateRange.value!.end.add(const Duration(days: 1)),
                ),
          )
          .toList();
    } else {
      if (selectedTab.value == 'Month') {
        temp = temp.where((i) => now.difference(i.date).inDays <= 30).toList();
      } else if (selectedTab.value == 'Year') {
        temp = temp.where((i) => now.difference(i.date).inDays <= 365).toList();
      }
    }

    // B. Sort
    if (isNewestFirst.value) {
      temp.sort((a, b) => b.date.compareTo(a.date));
    } else {
      temp.sort((a, b) => a.date.compareTo(b.date));
    }

    // C. Update UI
    historyItems.assignAll(temp);

    // Recalculate Totals
    int tc = 0;
    double tcost = 0;
    for (var i in temp) {
      tc += i.consumption;
      tcost += i.cost;
    }
    totalConsumption.value = tc;
    totalCost.value = tcost;
  }

  // 3. Interactions
  void changeTab(String tab) {
    selectedTab.value = tab;
    selectedDateRange.value = null; // Reset custom date if tab is clicked
    applyFilters();
  }

  void toggleSort() {
    isNewestFirst.value = !isNewestFirst.value;
    applyFilters();
  }

  void setDateRange(DateTimeRange range) {
    selectedDateRange.value = range;
    selectedTab.value = ''; // Clear tab selection
    applyFilters();
  }

  void addLocalReading(Reading reading, int consumption) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final date = reading.createdAt ?? DateTime.now();
    final formattedDate =
        "${monthNames[date.month - 1]} ${date.day}, ${date.year}";

    final newItem = HistoryItem(
      consumption: consumption,
      cost: reading.cost ?? 0,
      date: date,
      dateRange: formattedDate,
    );

    _allItems.add(newItem);

    applyFilters();
  }

  Future<void> clearHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    isLoading.value = true;
    final success = await _readingService.deleteAllReadings(userId);

    if (success) {
      _allItems.clear();
      applyFilters(); // Updates UI to empty

      Get.find<CalculatorPageController>().lastDbReading.value = 0;

      Get.snackbar(
        "Success".tr,
        "All history cleared successfully".tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Error".tr,
        "Failed to clear history".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    isLoading.value = false;
  }
}
