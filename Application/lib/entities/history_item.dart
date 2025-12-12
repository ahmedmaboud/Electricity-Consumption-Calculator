class HistoryItem {
  final int consumption;
  final double cost;
  final DateTime date;
  final String dateRange;

  HistoryItem({
    required this.consumption,
    required this.cost,
    required this.date,
    required this.dateRange, int? id,
  });
}
