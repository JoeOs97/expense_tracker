import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../data/models/expense.dart';

class CategoryLineChart extends StatelessWidget {
  final Map<String, List<_ChartPoint>> categoryPoints;
  final Map<String, Color> colors;

  const CategoryLineChart({
    super.key,
    required this.categoryPoints,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final List<CartesianSeries<_ChartPoint, String>> seriesList = categoryPoints.entries.map((entry) {
      final category = entry.key;
      final dataPoints = entry.value;
      final color = colors[category] ?? Colors.grey;

      return LineSeries<_ChartPoint, String>(
        dataSource: dataPoints,
        xValueMapper: (point, _) => point.day,
        yValueMapper: (point, _) => point.amount,
        name: category,
        color: color,
        width: 3,
        markerSettings: const MarkerSettings(isVisible: false),
        dataLabelSettings: const DataLabelSettings(isVisible: false),
         // smooth lines
      );
    }).toList();

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SfCartesianChart(
        title: ChartTitle(text: 'Weekly Spending by Category'),
        legend: const Legend(isVisible: true, position: LegendPosition.bottom),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: 'Days'),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Amount'),
        ),
        series: seriesList,
      ),
    );
  }
}

class _ChartPoint {
  final String day;
  final double amount;
  _ChartPoint(this.day, this.amount);
}

// --- Helper to group and convert data ---
Map<String, List<_ChartPoint>> groupExpensesByCategoryAndDay(List<Expense> expenses) {
  final now = DateTime.now();

  // Start of the week (Monday)
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

  // Create 7 days from Mon → Sun
  final thisWeekDays = List.generate(7, (i) {
    final day = startOfWeek.add(Duration(days: i));
    return DateTime(day.year, day.month, day.day);
  });

  final Map<String, Map<DateTime, double>> categoryDayTotals = {};

  for (final e in expenses) {
    final category = e.category.value?.name ?? "Other";
    final day = DateTime(e.date.year, e.date.month, e.date.day);

    if (thisWeekDays.contains(day)) {
      categoryDayTotals.putIfAbsent(category, () => {});
      categoryDayTotals[category]![day] =
          (categoryDayTotals[category]![day] ?? 0) + e.amount;
    }
  }

  const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Convert to chart points
  final Map<String, List<_ChartPoint>> categoryPoints = {};
  for (final entry in categoryDayTotals.entries) {
    final points = <_ChartPoint>[];
    for (int i = 0; i < thisWeekDays.length; i++) {
      final day = thisWeekDays[i];
      final y = entry.value[day] ?? 0;
      points.add(_ChartPoint(dayLabels[i], y));
    }
    categoryPoints[entry.key] = points;
  }

  return categoryPoints;
}
