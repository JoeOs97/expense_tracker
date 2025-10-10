import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';
import '../widgets/balance_overview_card.dart';
import '../widgets/categoryItemTotal.dart';
import '../widgets/expense_item.dart';
import '../viewmodels/totals_provider.dart';

class Homepage extends ConsumerWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseViewModelProvider);
    final incomes = ref.watch(incomeViewModelProvider);

    final totalExpenses = ref.watch(expenseViewModelProvider.notifier).totalExpenses;
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalBalance = ref.watch(totalBalanceProvider);

    final balanceSpots = List.generate(
      7,
          (i) => FlSpot(i.toDouble(), (totalBalance / 7) * (i + 1)),
    );

    // ✅ Combine expenses and incomes into one transaction list
    final transactions = [
      ...expenses.map((e) => {'type': 'expense', 'data': e}),
      ...incomes.map((i) => {'type': 'income', 'data': i}),
    ];

    // ✅ Sort by most recent date
    transactions.sort((a, b) {
      final aDate = (a['data'] as dynamic).date;
      final bDate = (b['data'] as dynamic).date;
      return bDate.compareTo(aDate);
    });

    // ✅ Take only 5 most recent
    final recentTransactions = transactions.take(5).toList();

    // ✅ Preset categories for chart
    final List<String> presetCategories = [
      'Food',
      'Transport',
      'Utilities',
      'Shopping',
      'Entertainment',
      'Health',
      'Education',
      'Housing',
      'Insurance',
      'Travel',
      'Savings',
      'Gifts',
      'Other',
    ];

    // ✅ Calculate total spent per category
    final Map<String, double> categoryExpenses = {};
    for (var exp in expenses) {
      final categoryName = exp.category.value?.name ?? 'Other';
      categoryExpenses[categoryName] =
          (categoryExpenses[categoryName] ?? 0) + exp.amount;
    }

    // ✅ Add missing categories with 0
    for (var cat in presetCategories) {
      categoryExpenses.putIfAbsent(cat, () => 0.0);
    }

    // ✅ Sort categories (non-zero first)
    final sortedEntries = categoryExpenses.entries.toList()
      ..sort((a, b) {
        if (b.value > 0 && a.value == 0) return 1;
        if (a.value > 0 && b.value == 0) return -1;
        return b.value.compareTo(a.value);
      });

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ✅ Greeting + Balance
            BalanceOverviewCard(
              userName: 'Zuzu',
              totalBalance: totalBalance,
              totalIncome: totalIncome,
              totalExpenses: totalExpenses,
              goalAmount: 5000,
              balanceSpots: balanceSpots,
              currency: '\$',
            ),

            const SizedBox(height: 16),

            // ✅ Category chart
            const Text(
              'Total Spent on Categories',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 325,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 5,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                ),
                itemCount: sortedEntries.length,
                itemBuilder: (context, index) {
                  final entry = sortedEntries[index];
                  final name = entry.key;
                  final total = entry.value;

                  IconData icon;
                  switch (name.toLowerCase()) {
                    case 'food':
                      icon = Icons.fastfood;
                      break;
                    case 'transport':
                      icon = Icons.directions_car;
                      break;
                    case 'shopping':
                      icon = Icons.shopping_bag;
                      break;
                    case 'entertainment':
                      icon = Icons.movie;
                      break;
                    case 'utilities':
                      icon = Icons.lightbulb;
                      break;
                    case 'health':
                      icon = Icons.health_and_safety;
                      break;
                    case 'education':
                      icon = Icons.menu_book_outlined;
                      break;
                    case 'housing':
                      icon = Icons.home;
                      break;
                    case 'travel':
                      icon = Icons.airplanemode_active;
                      break;
                    case 'gifts':
                      icon = Icons.card_giftcard;
                      break;
                    case 'insurance':
                      icon = Icons.attach_money;
                      break;
                    case 'savings':
                      icon = Icons.savings;
                      break;
                    default:
                      icon = Icons.category;
                  }

                  final textColor = total > 0 ? Colors.green : Colors.grey;

                  return CategoryCard(
                    categoryName: name,
                    totalSpent: total,
                    icon: icon,
                    color: Colors.teal,
                    onTap: () => print('Tapped $name'),
                    textColor: textColor,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Recent Transactions
            const Text(
              'Recent Transactions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),

            if (recentTransactions.isEmpty)
              const Center(child: Text('No transactions found'))
            else
              ...recentTransactions.map((t) {
                final data = t['data'];
                final type = t['type'];

                return TransactionCard(
                  transaction: data,
                  isIncome: type == 'income',
                );
              }),
          ],
        ),
      ),
    );
  }
}
