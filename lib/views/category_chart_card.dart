import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../data/models/expense.dart';
import '../viewmodels/expense_viewmodel.dart';
import 'package:intl/intl.dart';

class CategoryChartPage extends ConsumerWidget {
  final String categoryName;

  const CategoryChartPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExpenses = ref.watch(expenseViewModelProvider);

    // Filter expenses by category
    final categoryExpenses = allExpenses
        .where((expense) => expense.category.value?.name == categoryName)
        .toList();

    // Group by date and sum amounts
    final Map<String, double> dailyTotals = {};
    for (var expense in categoryExpenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
      if (dailyTotals.containsKey(dateKey)) {
        dailyTotals[dateKey] = dailyTotals[dateKey]! + expense.amount;
      } else {
        dailyTotals[dateKey] = expense.amount;
      }
    }

    // Convert to a list for charting
    final chartData = dailyTotals.entries
        .map((e) => _DailyExpense(date: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    double totalSpent = chartData.fold(0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('$categoryName Expenses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Total spent: \$${totalSpent.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Chart
            Expanded(
              flex: 1,
              child: chartData.isEmpty
                  ? const Center(child: Text('No expenses yet'))
                  : SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: 'Date'),
                  labelRotation: 90,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Amount (\$)'),
                ),
                series: <ColumnSeries<_DailyExpense, String>>[
                  ColumnSeries<_DailyExpense, String>(
                    dataSource: chartData,
                    xValueMapper: (_DailyExpense e, _) => e.date,
                    yValueMapper: (_DailyExpense e, _) => e.amount,
                    color: Colors.teal,
                    width: 0.3, // thinner bar
                    borderRadius:
                    const BorderRadius.all(Radius.circular(6)),
                    dataLabelSettings:
                    const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // List of expenses
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: categoryExpenses.length,
                itemBuilder: (context, index) {
                  final e = categoryExpenses[index];
                  return ListTile(
                    title: Text(e.title),
                    trailing: Text('\$${e.amount.toStringAsFixed(2)}'),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(e.date)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for daily grouped data
class _DailyExpense {
  final String date;
  final double amount;

  _DailyExpense({required this.date, required this.amount});
}
