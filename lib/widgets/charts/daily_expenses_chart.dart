import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DailyExpensesChart extends StatelessWidget {
  final Map<DateTime, double> dailyExpenses;

  const DailyExpensesChart({super.key, required this.dailyExpenses});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (dailyExpenses.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Text('No data', style: TextStyle(color: Colors.grey)),
      );
    }

    final sortedDates = dailyExpenses.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    final data = sortedDates
        .map((d) => _DailyData(
      label: '${d.day}/${d.month}',
      date: d,
      amount: dailyExpenses[d] ?? 0.0,
    ))
        .toList();

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        tooltipBehavior: TooltipBehavior(enable: true, header: ''),
        primaryXAxis: CategoryAxis(
          labelRotation: 270,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 11),
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: const TextStyle(color: Colors.grey),
          majorGridLines: const MajorGridLines(width: 0.5),
        ),
        series: [
          ColumnSeries<_DailyData, String>(
            dataSource: data,
            xValueMapper: (_DailyData d, _) => d.label,
            yValueMapper: (_DailyData d, _) => d.amount,
            borderRadius: BorderRadius.circular(5),
            width: 0.2,
            color: const Color(0xFF0083B0),
            spacing: 0.2,
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
        ],
      ),
    );
  }
}

class _DailyData {
  final String label;
  final DateTime date;
  final double amount;
  _DailyData({required this.label, required this.date, required this.amount});
}
