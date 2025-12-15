// analytics_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:graduation_project_depi/controllers/analytics_page_controller.dart';

class AnalyticsView extends StatelessWidget {
  AnalyticsView({Key? key}) : super(key: key);

  // Theme Colors - will be dynamic based on theme
  Color getActiveColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF64B5F6)
        : const Color(0xFF2979FF);
  }

  Color getInactiveColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF424242)
        : const Color(0xFFE0E0E0);
  }

  // Helper to open details bottom sheet
  void _showPeriodDetails(
    BuildContext context,
    AnalyticsController ctrl,
    String label,
  ) {
    // This gets the INDIVIDUAL entries for that month (e.g. Dec 11, Dec 12)
    final entries = ctrl.entriesForAggLabel(label);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$label ${'Details'.tr}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (entries.isEmpty) Text("No records found.".tr),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final e = entries[i];
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.blue.shade900.withOpacity(0.5)
                                  : Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.flash_on,
                              color: isDark
                                  ? Colors.blue.shade300
                                  : Colors.blue,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            '${e.kwh.toStringAsFixed(1)} ${'KWH'.tr}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.titleMedium?.color,
                            ),
                          ),
                          // Shows specific date for this entry
                          subtitle: Text(
                            DateFormat.yMMMd().format(e.date),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                          ),
                          trailing: Text(
                            '\$${e.totalCost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.titleMedium?.color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure we find the controller
    final AnalyticsController ctrl = Get.find<AnalyticsController>();
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,

        title: Text(
          'Analytics'.tr,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              children: [
                _buildCustomToggle( context,ctrl),
                const SizedBox(height: 20),

                // Consumption Bar Chart
                Obx(() {
                  // Get aggregated data (SUMMED by month)
                  final labels = ctrl.aggLabels;
                  final values = ctrl.aggValues;

                  // Calculate total of the visible bars
                  final safeValues = values
                      .map((v) => (v.isFinite && v > 0) ? v : 0.0)
                      .toList();
                  final total = safeValues.fold<double>(0.0, (p, e) => p + e);

                  return SizedBox(
                    height: screenHeight * 0.4,
                    child: _buildConsumptionCard(
                      context,
                      ctrl,
                      labels,
                      safeValues,
                      total,
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Cost Breakdown
                Obx(() {
                  final idx = ctrl.selectedAggIndex.value;
                  CostBreakdown breakdown;
                  double totalCost;

                  if (idx >= 0 && idx < ctrl.aggLabels.length) {
                    final label = ctrl.aggLabels[idx];
                    // Get breakdown for the SUMMED period
                    breakdown = ctrl.aggregatedBreakdownForLabel(label);
                    totalCost = ctrl.totalCostForAggLabel(label);
                  } else {
                    if (ctrl.aggLabels.isNotEmpty) {
                      final lastLabel = ctrl.aggLabels.last;
                      breakdown = ctrl.aggregatedBreakdownForLabel(lastLabel);
                      totalCost = ctrl.totalCostForAggLabel(lastLabel);
                    } else {
                      breakdown = CostBreakdown(peak: 0, offPeak: 0, taxes: 0);
                      totalCost = 0.0;
                    }
                  }

                  return _buildCostBreakdownCard(context, breakdown, totalCost);
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomToggle(BuildContext context, AnalyticsController ctrl) {
    return Obx(() {
      final isMonthly = ctrl.mode.value == AnalyticsMode.monthly;
      return Container(
        height: 45,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF424242)
              : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _toggleItem(
                context,

                'Monthly'.tr,
                isMonthly,
                () => ctrl.setMode(AnalyticsMode.monthly),
              ),
            ),
            Expanded(
              child: _toggleItem(
                context,

                'Yearly'.tr,
                !isMonthly,
                () => ctrl.setMode(AnalyticsMode.yearly),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _toggleItem(
    BuildContext context,
    String title,
    bool isActive,
    VoidCallback onTap,
  ) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive
                ? Theme.of(context).textTheme.titleMedium?.color
                : Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildConsumptionCard(
    BuildContext context,
    AnalyticsController ctrl,
    List<String> labels,
    List<double> values,
    double total,
  ) {
    final maxY = ctrl.calculateMaxY(values);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consumption'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ctrl.mode.value == AnalyticsMode.monthly
                        ? 'Last %s Months'.trArgs([labels.length.toString()])
                        : 'Last %s Years'.trArgs([labels.length.toString()]),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                '${total.toInt()}  ${'KWH'.tr}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              // CORRECTED PLACEMENT: swapAnimationDuration is here now
              swapAnimationDuration: Duration.zero,
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.1,
                minY: 0,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length)
                          return const SizedBox.shrink();

                        String label = labels[index];
                        // If it's a Year (number), keep it. If it's a Month (text > 3), shorten it.
                        bool isYear = int.tryParse(label) != null;
                        if (!isYear && label.length > 3) {
                          label = label.substring(0, 3);
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        barTouchResponse == null ||
                        barTouchResponse.spot == null) {
                      return;
                    }
                    final touchedIndex =
                        barTouchResponse.spot!.touchedBarGroupIndex;
                    ctrl.selectAggIndex(touchedIndex);

                    if (event is FlTapUpEvent) {
                      _showPeriodDetails(context, ctrl, labels[touchedIndex]);
                    }
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[900]!
                        : Colors.black87,
                    tooltipBorderRadius: BorderRadius.circular(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} ${'KWH'.tr}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: List.generate(values.length, (i) {
                  final isSelected = i == ctrl.highlightedIndex;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        color: isSelected
                            ? getActiveColor(context)
                            : getInactiveColor(context),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                          bottom: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(show: false),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostBreakdownCard(
    BuildContext context,
    CostBreakdown breakdown,
    double totalCost,
  ) {
    final activeColor = getActiveColor(context);
    final inactiveColor = getInactiveColor(context);
    final offPeakColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF90CAF9)
        : const Color(0xFF64B5F6);

    final sections = [
      PieChartSectionData(
        color: activeColor,
        value: breakdown.peak,
        radius: 12,
        showTitle: false,
      ),
      PieChartSectionData(
        color: offPeakColor,
        value: breakdown.offPeak,
        radius: 12,
        showTitle: false,
      ),
      PieChartSectionData(
        color: inactiveColor,
        value: breakdown.taxes,
        radius: 12,
        showTitle: false,
      ),
    ];

    final isEmpty = breakdown.total == 0;
    final emptyColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]
        : Colors.grey[200];
    final displaySections = isEmpty
        ? [
            PieChartSectionData(
              color: emptyColor!,
              value: 1,
              radius: 12,
              showTitle: false,
            ),
          ]
        : sections;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cost Breakdown'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: Stack(
                  children: [
                    PieChart(
                      // CORRECTED PLACEMENT: swapAnimationDuration is here now
                      swapAnimationDuration: Duration.zero,
                      PieChartData(
                        sections: displaySections,
                        centerSpaceRadius: 55,
                        sectionsSpace: 0,
                        startDegreeOffset: 270,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Total".tr,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${totalCost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(
                                context,
                              ).textTheme.titleLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendItem(
                      context,
                      activeColor,
                      'Peak Hours'.tr,
                      breakdown.peak,
                    ),
                    const SizedBox(height: 12),
                    _legendItem(
                      context,
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF90CAF9)
                          : const Color(0xFF64B5F6),
                      'Off-Peak'.tr,
                      breakdown.offPeak,
                    ),
                    const SizedBox(height: 12),
                    _legendItem(
                                            context,

                      inactiveColor,
                      'Taxes & Fees'.tr,
                      breakdown.taxes,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(     BuildContext context,
Color color, String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(                color: Theme.of(context).textTheme.bodySmall?.color,
 fontSize: 10),
            ),
          ],
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,  color: Theme.of(context).textTheme.titleMedium?.color,),
        ),
      ],
    );
  }
}
