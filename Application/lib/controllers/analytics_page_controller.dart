import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/entities/reading.dart';
import 'package:graduation_project_depi/services/electricity_reading_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  CostBreakdown operator +(CostBreakdown other) =>
      CostBreakdown(peak: peak + other.peak, offPeak: offPeak + other.offPeak, taxes: taxes + other.taxes);
}

class ConsumptionEntry {
  final int id;
  final DateTime date;
  final double kwh;
  final double totalCost;
  final CostBreakdown breakdown;

  ConsumptionEntry({
    required this.id,
    required this.date,
    required this.kwh,
    required this.totalCost,
    required this.breakdown,
  });
}

class AnalyticsController extends GetxController {
  final Rx<AnalyticsMode> mode = AnalyticsMode.monthly.obs;
  final RxList<ConsumptionEntry> entries = <ConsumptionEntry>[].obs;
  final RxMap<String, double> monthlyData = <String, double>{}.obs;
  final RxMap<String, double> yearlyData = <String, double>{}.obs;
  final Rx<CostBreakdown> cost = CostBreakdown(peak: 0, offPeak: 0, taxes: 0).obs;
  final RxInt selectedAggIndex = RxInt(-1);

  late final ElectricityReadingService _readingService;
  late final SupabaseClient _supabase;
  
  StreamSubscription? _entriesSub;
  StreamSubscription? _authSub;

  @override
  void onInit() {
    super.onInit();
    _readingService = Get.find<ElectricityReadingService>();
    _supabase = Get.find<SupabaseClient>();

    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        loadEntries();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadEntries();
      
      _entriesSub = entries.listen((_) => _rebuildAggregates());
      mode.listen((_) => selectedAggIndex.value = -1);
    });
  }

  @override
  void onClose() {
    _entriesSub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }

  Future<void> loadEntries() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return; 

      final List<Reading> userReadings = await _readingService.getUserReadings(userId);

      // We need at least 2 readings to show a valid "Consumption" bar
      if (userReadings.isEmpty) {
        entries.clear();
        _rebuildAggregates();
        cost.value = CostBreakdown(peak: 0, offPeak: 0, taxes: 0);
        return;
      }

      userReadings.sort((a, b) => _safeDate(a.createdAt).compareTo(_safeDate(b.createdAt)));

      final List<ConsumptionEntry> loaded = [];

      // --- FIX: Start loop at 1 to skip the first reading ---
      // This hides the "First Consumption" spike and only shows usage relative to a previous reading.
      for (int i = 1; i < userReadings.length; i++) {
        final curr = userReadings[i];
        final prev = userReadings[i - 1]; // We can safely access i-1 now

        final DateTime dateCurr = _safeDate(curr.createdAt);
        final double meterCurr = _safeMeter(curr.meterValue);
        final double meterPrev = _safeMeter(prev.meterValue);

        final double kwh = (meterCurr - meterPrev).isFinite ? (meterCurr - meterPrev) : 0.0;
        final double totalCost = (curr.cost ?? 0.0).isFinite ? curr.cost ?? 0.0 : 0.0;

        final breakdown = CostBreakdown(
          peak: totalCost * 0.25,
          offPeak: totalCost * 0.6,
          taxes: totalCost * 0.15,
        );

        final int entryId = _safeId(curr.id);

        loaded.add(ConsumptionEntry(
          id: entryId,
          date: dateCurr,
          kwh: max(0.0, kwh),
          totalCost: totalCost,
          breakdown: breakdown,
        ));
      }

      entries.assignAll(loaded);
      if (entries.isNotEmpty) cost.value = entries.last.breakdown;

    } catch (e) {
      debugPrint('AnalyticsController: loadEntries failed: $e');
    }
  }

  void refreshData() => loadEntries();

  // --- REVERTED: Getters now return full data (The filtering is done in loadEntries) ---
  void _rebuildAggregates() {
    monthlyData.clear();
    yearlyData.clear();
    for (final e in entries) {
      final monthKey = '${_monthName(e.date.month)} ${e.date.year}';
      monthlyData[monthKey] = (monthlyData[monthKey] ?? 0.0) + e.kwh;
      final yearKey = e.date.year.toString();
      yearlyData[yearKey] = (yearlyData[yearKey] ?? 0.0) + e.kwh;
    }
  }

  // REVERTED: No sublist here. Displays exactly what is in 'entries'.
  List<String> get aggLabels => (mode.value == AnalyticsMode.monthly) ? monthlyData.keys.toList() : yearlyData.keys.toList();
  
  // REVERTED: No sublist here.
  List<double> get aggValues => (mode.value == AnalyticsMode.monthly) ? monthlyData.values.toList() : yearlyData.values.toList();

  DateTime _safeDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }

  double _safeMeter(dynamic raw) {
    if (raw == null) return 0.0;
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0.0;
    return 0.0;
  }

  int _safeId(dynamic raw) {
    if (raw == null) return 0;
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final i = (m - 1).clamp(0, 11);
    return months[i];
  }

  double get totalConsumption => aggValues.fold<double>(0.0, (p, e) => p + (e.isFinite ? e : 0.0));
  ConsumptionEntry? get latest => entries.isNotEmpty ? entries.last : null;
  int get highlightedIndex {
    final vals = aggValues;
    if (vals.isEmpty) return -1;
    if (selectedAggIndex.value != -1) return selectedAggIndex.value;
    return vals.length - 1;
  }

  void selectAggIndex(int index) => selectedAggIndex.value = index;
  void clearSelection() => selectedAggIndex.value = -1;

  List<ConsumptionEntry> entriesForAggLabel(String label) {
    if (mode.value == AnalyticsMode.monthly) {
      final parts = label.split(' ');
      if (parts.length < 2) return [];
      final monthName = parts[0];
      final year = int.tryParse(parts[1]) ?? -1;
      final monthIndex = _monthIndexByName(monthName);
      if (monthIndex < 1 || year < 0) return [];
      return entries.where((e) => e.date.month == monthIndex && e.date.year == year).toList();
    } else {
      final year = int.tryParse(label) ?? -1;
      if (year < 0) return [];
      return entries.where((e) => e.date.year == year).toList();
    }
  }

  double totalKwhForAggLabel(String label) => entriesForAggLabel(label).fold(0.0, (p, e) => p + e.kwh);
  double totalCostForAggLabel(String label) => entriesForAggLabel(label).fold(0.0, (p, e) => p + e.totalCost);
  CostBreakdown aggregatedBreakdownForLabel(String label) {
    var acc = CostBreakdown(peak: 0, offPeak: 0, taxes: 0);
    for (final e in entriesForAggLabel(label)) {
      acc = acc + e.breakdown;
    }
    return acc;
  }

  int _monthIndexByName(String name) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final idx = months.indexOf(name);
    return idx >= 0 ? idx + 1 : -1;
  }

  void setMode(AnalyticsMode newMode) => mode.value = newMode;
  void toggleMode() => mode.value = (mode.value == AnalyticsMode.monthly) ? AnalyticsMode.yearly : AnalyticsMode.monthly;

  double calculateMaxY(List<double> vals) {
    final cleaned = vals.where((v) => v.isFinite && v > 0).toList();
    if (cleaned.isEmpty) return 10.0;
    final maxVal = cleaned.reduce(max);
    if (!(maxVal.isFinite) || maxVal <= 0) return 10.0;
    final magnitude = pow(10, max(0, (log(maxVal) / ln10).floor()));
    final niceBase = maxVal / magnitude;
    double multiplier = (niceBase <= 1) ? 1 : (niceBase <= 2) ? 2 : (niceBase <= 5) ? 5 : 10;
    return max(multiplier * magnitude, maxVal * 1.1);
  }
  double niceInterval(List<double> vals) {
    final maxY = calculateMaxY(vals);
    if (!(maxY.isFinite) || maxY <= 0) return 1.0;
    final raw = maxY / 4.0;
    final rounded = raw.roundToDouble();
    return max(1.0, rounded);
  }

    Map<String, List<String>> months = {
    'en': ['', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
    'ar': ['', 'يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'],
  };


  // small date formatter
  String _shortMonthDay(DateTime d) {
    final lang = Get.locale?.languageCode ?? 'en';
    final monthList = months[lang]!;
    return '${monthList[d.month]} ${d.day}';

  }
}