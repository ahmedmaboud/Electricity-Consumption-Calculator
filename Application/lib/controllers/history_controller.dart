import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/services/electricity_reading_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/history_item.dart';
import '../entities/reading.dart';
import 'calculator_page_controller.dart';
import 'analytics_page_controller.dart'; 

class HistoryController extends GetxController {
  final _readingService = Get.find<ElectricityReadingService>();
  final _supabase = Get.find<SupabaseClient>();

  final List<HistoryItem> _allItems = [];
  final historyItems = <HistoryItem>[].obs;
  final isLoading = true.obs;

  final selectedTab = 'Month'.obs;
  final isNewestFirst = true.obs;
  final selectedDateRange = Rxn<DateTimeRange>();

  final totalConsumption = 0.obs;
  final totalCost = RxDouble(0);
  
  StreamSubscription? _authSub;

  @override
  void onInit() {
    super.onInit();
    
    // Listen for Auth to load data on app restart
    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        fetchHistory();
      }
    });
    
    // Also try fetching immediately
    fetchHistory();
  }
  
  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  Future<void> fetchHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    final readings = await _readingService.getUserReadings(userId);

    readings.sort(
      (a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()),
    );

    _allItems.clear();
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    for (int i = 0; i < readings.length; i++) {
      int consumption = 0;
      if (i + 1 < readings.length) {
        consumption = readings[i].meterValue - readings[i + 1].meterValue;
      } else {
        consumption = 0;
      }
      if (consumption < 0) consumption = 0;

      final date = readings[i].createdAt ?? DateTime.now();
      final formattedDate = "${monthNames[date.month - 1]} ${date.day}, ${date.year}";
      
      int? rId;
      if (readings[i].id is int) rId = readings[i].id as int;
      else if (readings[i].id is String) rId = int.tryParse(readings[i].id as String);

      _allItems.add(
        HistoryItem(
          id: rId, 
          consumption: consumption,
          cost: readings[i].cost ?? 0,
          date: date,
          dateRange: formattedDate,
        ),
      );
    }

    applyFilters();
    isLoading.value = false;
  }

  Future<void> deleteReading(int id) async {
    bool success = await _readingService.deleteReading(id);
    if (success) {
      if (Get.isRegistered<AnalyticsController>()) {
        Get.find<AnalyticsController>().refreshData();
      }
      fetchHistory();
      Get.snackbar('Success', 'Reading deleted');
    } else {
      Get.snackbar('Error', 'Could not delete reading');
    }
  }

  Future<void> clearHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    isLoading.value = true;
    final success = await _readingService.deleteAllReadings(userId);

    if (success) {
      _allItems.clear();
      applyFilters();

      if (Get.isRegistered<CalculatorPageController>()) {
        Get.find<CalculatorPageController>().lastDbReading.value = 0;
      }
      if (Get.isRegistered<AnalyticsController>()) {
        Get.find<AnalyticsController>().refreshData();
      }

      Get.snackbar("Success", "All history cleared", backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar("Error", "Failed to clear history", backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading.value = false;
  }

  void applyFilters() {
    List<HistoryItem> temp = List.from(_allItems);
    final now = DateTime.now();

    if (selectedDateRange.value != null) {
      temp = temp.where((i) => i.date.isAfter(selectedDateRange.value!.start) && i.date.isBefore(selectedDateRange.value!.end.add(const Duration(days: 1)))).toList();
    } else {
      if (selectedTab.value == 'Month') {
        temp = temp.where((i) => now.difference(i.date).inDays <= 30).toList();
      } else if (selectedTab.value == 'Year') {
        temp = temp.where((i) => now.difference(i.date).inDays <= 365).toList();
      }
    }

    if (isNewestFirst.value) {
      temp.sort((a, b) => b.date.compareTo(a.date));
    } else {
      temp.sort((a, b) => a.date.compareTo(b.date));
    }

    historyItems.assignAll(temp);

    int tc = 0;
    double tcost = 0;
    for (var i in temp) {
      tc += i.consumption;
      tcost += i.cost;
    }
    totalConsumption.value = tc;
    totalCost.value = tcost;
  }
  
  void changeTab(String tab) {
    selectedTab.value = tab;
    selectedDateRange.value = null;
    applyFilters();
  }

  void toggleSort() {
    isNewestFirst.value = !isNewestFirst.value;
    applyFilters();
  }

  void setDateRange(DateTimeRange range) {
    selectedDateRange.value = range;
    selectedTab.value = '';
    applyFilters();
  }

  void addLocalReading(Reading reading, int consumption) {
     fetchHistory();
  }
}