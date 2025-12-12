import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/controllers/history_controller.dart';
import '../entities/history_item.dart';
import 'package:graduation_project_depi/controllers/language_controller.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final langController = Get.find<LanguageController>();

    if (!Get.isRegistered<HistoryController>()) {
      Get.put(HistoryController());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          "Consumption History".tr,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: "Reset History".tr,
            onPressed: () => _showDeleteConfirmation(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: SpinKitThreeBounce(color: Color(0xFF1976D2), size: 30),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // 1. Dynamic Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.selectedDateRange.value != null
                            ? "Selected Range Total".tr
                            :"${'Total For'.tr} (${controller.selectedTab.value.tr})",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              "${controller.totalConsumption.value} ${'KWH'.tr}",
                              key: ValueKey(controller.totalConsumption.value),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          "${controller.totalCost.value.toStringAsFixed(2)} ${'currency'.tr}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 2. Interactive Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [_buildTab("Month".tr), _buildTab("Year".tr)]),
                ),

                const SizedBox(height: 20),

                // 3. Interactive Filters
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterButton(
                        icon: Icons.swap_vert,
                        label: controller.isNewestFirst.value
                            ? "${'Sort'.tr}: ${'Newest'.tr}"
                            : "${'Sort'.tr}: ${'Oldest'.tr}",
                        onTap: () => controller.toggleSort(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterButton(
                        icon: Icons.calendar_today,
                        label: "Filter Date".tr,
                        onTap: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            controller.setDateRange(picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 4. List Items
                Expanded(
                  child: controller.historyItems.isEmpty
                      ? Center(
                          child: Text(
                            "No readings found for this period.".tr,
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        )
                      : ListView.separated(
                          itemCount: controller.historyItems.length,
                          separatorBuilder: (c, i) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = controller.historyItems[index];
                            return _buildHistoryItem(item);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Reset History".tr),
        content: Text(
          "Are you sure you want to delete ALL reading history? This action cannot be undone.".tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel".tr, style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearHistory();
            },
            child: Text(
              "Delete All".tr,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTab(String text) {
    final isSelected = controller.selectedTab.value == text;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(text),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(HistoryItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bolt, color: Color(0xFF1976D2), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${item.consumption} ${'KWH'.tr}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.dateRange,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            "${item.cost.toStringAsFixed(2)} ${'currency'.tr}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
