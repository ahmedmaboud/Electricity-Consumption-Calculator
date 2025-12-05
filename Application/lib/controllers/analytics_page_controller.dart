// analytics_controller.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

enum AnalyticsMode { monthly, yearly }

class CostBreakdown {
  double peak;
  double offPeak;
  double taxes;
  CostBreakdown({
    required this.peak,
    required this.offPeak,
    required this.taxes,
  });

  double get total => peak + offPeak + taxes;
}

/// New: a single timestamped consumption record
class ConsumptionEntry {
  final DateTime date;
  final double kwh;
  final double totalCost;
  final CostBreakdown breakdown;

  ConsumptionEntry({
    required this.date,
    required this.kwh,
    required this.totalCost,
    required this.breakdown,
  });
}

class AnalyticsController extends GetxController {
  // mode toggle
  final Rx<AnalyticsMode> mode = AnalyticsMode.monthly.obs;

  // Keep a list of timestamped entries (ordered by time ascending)
  final RxList<ConsumptionEntry> entries = <ConsumptionEntry>[].obs;

  // Convenience maps derived from entries for charting by month/year if needed
  final RxMap<String, double> monthlyData = <String, double>{}.obs;
  final RxMap<String, double> yearlyData = <String, double>{}.obs;

  // cost breakdown for the most recent entry (for donut)
  final Rx<CostBreakdown> cost = CostBreakdown(peak: 0, offPeak: 0, taxes: 0).obs;

  StreamSubscription? _entriesSub;

  @override
  void onInit() {
    super.onInit();

    // Defer seeding/subscriptions until after first frame to avoid build-time mutations.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // seed month placeholders if empty (optional)
      if (monthlyData.isEmpty) {
        monthlyData.addAll({
          'Jan': 0.0,
          'Feb': 0.0,
          'Mar': 0.0,
          'Apr': 0.0,
          'May': 0.0,
          'Jun': 0.0,
        });
      }

      // If entries change, rebuild monthly/yearly derived maps automatically
      _entriesSub = entries.listen((list) {
        _rebuildDerivedMaps();
      });
    });
  }

  @override
  void onClose() {
    _entriesSub?.cancel();
    super.onClose();
  }

  // Derived labels for the view: if monthly mode, return formatted dates (e.g. "Jun 12")
  List<String> get labels {
    if (mode.value == AnalyticsMode.monthly) {
      return entries.map((e) => _shortMonthDay(e.date)).toList();
    } else {
      // yearly: show year + maybe month count; use year string
      return entries.map((e) => e.date.year.toString()).toList();
    }
  }

  // Values for the chart (kWh)
  List<double> get values => entries.map((e) => (e.kwh.isFinite && e.kwh > 0) ? e.kwh : 0.0).toList();

  double get totalConsumption => values.fold<double>(0.0, (p, e) => p + (e.isFinite ? e : 0.0));

  // Latest entry (or null)
  ConsumptionEntry? get latest => entries.isNotEmpty ? entries.last : null;

  int get highlightedIndex {
    final vals = values;
    if (vals.isEmpty) return -1;
    final filtered = vals.where((v) => v.isFinite).toList();
    if (filtered.isEmpty) return -1;
    final maxVal = filtered.reduce(max);
    return vals.indexOf(maxVal);
  }

  // Primary API: call this from CalculatorPageController after compute.
  // date is required so you can pass the exact date/time of the reading.
  void updateFromConsumption(double kwh, double totalCost, DateTime date) {
    // sanitize numbers
    final safeKwh = (kwh.isFinite && kwh > 0) ? kwh : 0.0;
    final safeTotalCost = (totalCost.isFinite && totalCost > 0) ? totalCost : 0.0;

    // Create cost breakdown (replace with real algorithm if available)
    final peak = safeTotalCost * 0.25;
    final offPeak = safeTotalCost * 0.6;
    final taxes = safeTotalCost * 0.15;
    final breakdown = CostBreakdown(peak: peak, offPeak: offPeak, taxes: taxes);

    // create entry and push to list (keeps chronological order)
    final entry = ConsumptionEntry(date: date, kwh: safeKwh, totalCost: safeTotalCost, breakdown: breakdown);

    // If an entry for the same day exists, replace it; otherwise append
    final sameDayIndex = entries.indexWhere((e) =>
        e.date.year == date.year && e.date.month == date.month && e.date.day == date.day);
    if (sameDayIndex >= 0) {
      entries[sameDayIndex] = entry;
    } else {
      entries.add(entry);
    }

    // update latest cost donut
    cost.value = breakdown;

    // rebuild derived maps
    _rebuildDerivedMaps();
  }

  // Rebuild monthlyData/yearlyData from entries
  void _rebuildDerivedMaps() {
    // monthlyData keyed by short month (e.g. "Jun 12") or month name depending on needs.
    monthlyData.clear();
    yearlyData.clear();

    for (final e in entries) {
      final monthKey = _shortMonthDay(e.date); // e.g., "Jun 12"
      monthlyData[monthKey] = e.kwh;

      final yearKey = e.date.year.toString();
      yearlyData[yearKey] = (yearlyData[yearKey] ?? 0.0) + e.kwh;
    }
  }

  // Convenience: external update
  void updateMonthlyData(Map<String, double> newMap) {
    monthlyData
      ..clear()
      ..addAll(newMap.map((k, v) => MapEntry(k, (v.isFinite && v > 0) ? v : 0.0)));
  }

  void updateYearlyData(Map<String, double> newMap) {
    yearlyData
      ..clear()
      ..addAll(newMap.map((k, v) => MapEntry(k, (v.isFinite && v > 0) ? v : 0.0)));
  }

  void updateCostBreakdown(CostBreakdown newCost) {
    cost.value = CostBreakdown(
      peak: newCost.peak.isFinite && newCost.peak > 0 ? newCost.peak : 0.0,
      offPeak: newCost.offPeak.isFinite && newCost.offPeak > 0 ? newCost.offPeak : 0.0,
      taxes: newCost.taxes.isFinite && newCost.taxes > 0 ? newCost.taxes : 0.0,
    );
  }

  // mode control
  void setMode(AnalyticsMode newMode) => mode.value = newMode;
  void toggleMode() => mode.value = (mode.value == AnalyticsMode.monthly) ? AnalyticsMode.yearly : AnalyticsMode.monthly;

  // helpers for nice chart scaling (view can call)
  double calculateMaxY(List<double> vals) {
    final cleaned = vals.where((v) => v.isFinite && v > 0).toList();
    if (cleaned.isEmpty) return 10.0;
    final maxVal = cleaned.reduce(max);
    if (!(maxVal.isFinite) || maxVal <= 0) return 10.0;

    final magnitude = pow(10, max(0, (log(maxVal) / ln10).floor()));
    final niceBase = maxVal / magnitude;
    double multiplier;
    if (niceBase <= 1) multiplier = 1;
    else if (niceBase <= 2) multiplier = 2;
    else if (niceBase <= 5) multiplier = 5;
    else multiplier = 10;

    final nice = multiplier * magnitude;
    return max(nice, maxVal * 1.1);
  }

  double niceInterval(List<double> vals) {
    final maxY = calculateMaxY(vals);
    if (!(maxY.isFinite) || maxY <= 0) return 1.0;
    final raw = maxY / 4.0;
    final rounded = raw.roundToDouble();
    return max(1.0, rounded);
  }

  // small date formatter
  String _shortMonthDay(DateTime d) {
    final months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month]} ${d.day}';
  }
}
