import 'package:expense_tracker/viewmodels/expense_viewmodel.dart';
import 'package:expense_tracker/widgets/charts/category_expenses_charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/expense.dart';
import '../widgets/charts/daily_expenses_chart.dart';
import 'dart:math';

import '../widgets/charts/linechart.dart';

class StatisticsView extends ConsumerWidget {
  StatisticsView({super.key});

  final categoryColors = {
    'Food': Colors.teal,
    'Transport': Colors.orange,
    'Utilities': Colors.purple,
    'Shopping': Colors.green,
    'Entertainment': Colors.blue,
    'Health': Colors.red,
    'Education': Colors.brown,
    'Housing': Colors.indigo,
    'Insurance': Colors.cyan,
    'Travel': Colors.deepOrange,
    'Savings': Colors.lime,
    'Gifts': Colors.pink,
    'Other': Colors.grey,
  };
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👇 ref.watch returns the list of expenses directly
    final expenses = ref.watch(expenseViewModelProvider);

    if (expenses.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No data yet")),
      );
    }

    final dailyExpenses = _groupByDay(expenses);

// 🧩 Debug print to verify grouping
    _groupByCategory(expenses).forEach((key, value) {
    });

    final categoryExpenses = _groupByCategory(expenses);
    final categorySpots = groupExpensesByCategoryAndDay(expenses);


    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 250,
                child: DailyExpensesChart(dailyExpenses: dailyExpenses),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: CategoryLineChart(

                  colors: categoryColors, categoryPoints: categorySpots,
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: CategoryExpensesPieChart(
                  categoryExpenses: categoryExpenses,
                  categoryColors: categoryColors,
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }

  // --- Helper: Group total by day
  Map<DateTime, double> _groupByDay(List<Expense> expenses) {
    final Map<DateTime, double> dailyTotals = {};
    for (var e in expenses) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + e.amount;
    }
    return dailyTotals;
  }

  Map<String, double> _groupByCategory(List<Expense> expenses) {
    final categoryTotals = <String, double>{};

    for (final expense in expenses) {
      final categoryName = expense.category.value?.name ?? 'Other';
      categoryTotals[categoryName] =
          (categoryTotals[categoryName] ?? 0) + expense.amount;
    }

    if (categoryTotals.isEmpty) return {};

    // ✅ Apply logarithmic scaling for better visual balance
    final scaledTotals = categoryTotals.map((key, value) {
      // log10 smooths out extreme values
      final scaled = log(value + 1); // +1 avoids log(0)
      return MapEntry(key, scaled);
    });

    // ✅ Normalize again after log-scaling
    final total = scaledTotals.values.fold(0.0, (sum, v) => sum + v);
    final normalized = scaledTotals.map((key, value) {
      return MapEntry(key, (value / total) * 100);
    });

    print('🟣 Log-scaled normalized: $normalized');
    return normalized;
  }



}
