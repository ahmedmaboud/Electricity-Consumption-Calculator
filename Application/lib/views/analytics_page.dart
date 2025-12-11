// analytics_view.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:graduation_project_depi/controllers/analytics_page_controller.dart';


class AnalyticsView extends StatelessWidget {
  AnalyticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AnalyticsController ctrl = Get.find<AnalyticsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics'.tr),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 6),
            _modeToggle(ctrl),
            const SizedBox(height: 12),
            Obx(() {
              final labels = ctrl.labels;
              final values = ctrl.values;
              final safeValues = values.map((v) => (v.isFinite && v > 0) ? v : 0.0).toList();
              final total = safeValues.fold<double>(0.0, (p, e) => p + e);
              return _consumptionCard(ctrl, labels, safeValues, total);
            }),
            const SizedBox(height: 16),
            Obx(() => _costBreakdown(ctrl, ctrl.latest)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _modeToggle(AnalyticsController ctrl) {
    return Obx(() {
      final isMonthly = ctrl.mode.value == AnalyticsMode.monthly;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ToggleButtons(
            isSelected: [isMonthly, !isMonthly],
            onPressed: (i) => ctrl.setMode(i == 0 ? AnalyticsMode.monthly : AnalyticsMode.yearly),
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            fillColor: Colors.blueAccent,
            color: Colors.black87,
            children: [
              Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Text('Monthly'.tr)),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Text('Yearly'.tr)),
            ],
          ),
        ],
      );
    });
  }
  Widget _consumptionCard(AnalyticsController ctrl, List<String> labels, List<double> values, double total) {
    final maxY = ctrl.calculateMaxY(values);
    final interval = ctrl.niceInterval(values);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
             Text('Consumption'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${total.toStringAsFixed(2)} ${'KWH'.tr}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${'last'.tr} ${labels.length} ${ctrl.mode.value == AnalyticsMode.monthly ? 'months'.tr : 'years'.tr}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ]),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        // group.x is the index
                        final idx = group.x.toInt();
                        final label = (idx >= 0 && idx < ctrl.entries.length) ? ctrl.labels[idx] : '';
                        final entry = (idx >= 0 && idx < ctrl.entries.length) ? ctrl.entries[idx] : null;
                        final kwh = entry?.kwh ?? rod.toY;
                        final cost = entry?.totalCost ?? 0.0;
                        return BarTooltipItem(
                          '${label.tr}\n${kwh.toStringAsFixed(2)} ${'KWH'.tr}\n\$${cost.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: interval,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                          final label = labels[idx];
                          // if label longer than 6 chars, split or trim
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(label, style: const TextStyle(fontSize: 11)),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _makeBarGroups(values, ctrl.highlightedIndex),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  List<BarChartGroupData> _makeBarGroups(List<double> values, int highlightedIndex) {
    return List.generate(values.length, (i) {
      final rawVal = (i < values.length) ? values[i] : 0.0;
      final val = (rawVal.isFinite && rawVal > 0) ? rawVal : 0.0;
      final isHighlighted = i == highlightedIndex;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: val, width: 18, borderRadius: BorderRadius.circular(6), color: isHighlighted ? Colors.blueAccent : Colors.grey[300]),
        ],
      );
    });
  }

  Widget _costBreakdown(AnalyticsController ctrl, ConsumptionEntry? latestEntry) {
    final cb = latestEntry?.breakdown ?? CostBreakdown(peak: 0, offPeak: 0, taxes: 0);
    final total = latestEntry?.totalCost ?? cb.total;
    final dateText = latestEntry != null ? '${latestEntry.date.year}-${latestEntry.date.month.toString().padLeft(2, '0')}-${latestEntry.date.day.toString().padLeft(2, '0')}' : 'N/A'.tr;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(children: [
          // small donut showing cost breakdown
          SizedBox(
            width: 90,
            height: 90,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 24,
                sections: [
                  PieChartSectionData(value: cb.peak, title: '', radius: 24, color: Colors.blueAccent),
                  PieChartSectionData(value: cb.offPeak, title: '', radius: 24, color: Colors.lightBlueAccent.withOpacity(0.6)),
                  PieChartSectionData(value: cb.taxes, title: '', radius: 24, color: Colors.grey[300]),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
               Text('Last Reading'.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text( '${'date'.tr} $dateText', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              Text(  '${'total'.tr} \$${total.toStringAsFixed(2)}',style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
              const SizedBox(height: 8),
              _costRow('Peak Hours'.tr, cb.peak),
              _costRow('Off-Peak'.tr, cb.offPeak),
              _costRow('Taxes & Fees'.tr, cb.taxes),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _costRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
