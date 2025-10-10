import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';
import '../widgets/expense_item.dart'; // contains TransactionCard
import '../data/models/expense.dart';
import '../data/models/income.dart';

class ExpenseListPage extends ConsumerWidget {
  const ExpenseListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseViewModel = ref.watch(expenseViewModelProvider.notifier);
    final incomeViewModel = ref.watch(incomeViewModelProvider.notifier);

    final expenses = ref.watch(expenseViewModelProvider);
    final incomes = ref.watch(incomeViewModelProvider);

    // Load both datasets if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (expenses.isEmpty) expenseViewModel.loadExpenses();
      if (incomes.isEmpty) incomeViewModel.loadIncomes();
    });

    // Merge all transactions (income + expense) into a single list
    final allTransactions = [
      ...expenses.map((e) => _TransactionWrapper(
        id: e.id,
        object: e,
        isIncome: false,
      )),
      ...incomes.map((i) => _TransactionWrapper(
        id: i.id,
        object: i,
        isIncome: true,
      )),
    ]..sort((a, b) =>
        b.object.date.compareTo(a.object.date)); // sort latest first

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: allTransactions.isEmpty
          ? const Center(child: Text('No transactions found'))
          : ListView.builder(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: allTransactions.length,
        itemBuilder: (context, index) {
          final tx = allTransactions[index];
          return TransactionCard(
            transaction: tx.object,
            isIncome: tx.isIncome,
            onDelete: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Transaction'),
                  content: const Text(
                      'Are you sure you want to delete this transaction?'),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                if (tx.isIncome) {
                  await incomeViewModel.deleteIncome(tx.id);
                } else {
                  await expenseViewModel.deleteExpense(tx.id);
                }
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.limeAccent,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.remove_circle_outline,
                          color: Colors.red),
                      title: const Text('Add Expense'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add_circle_outline,
                          color: Colors.green),
                      title: const Text('Add Income'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/addIncome');
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }
}

/// ✅ Helper wrapper class for unified transaction list
class _TransactionWrapper {
  final int id;
  final dynamic object; // Expense or Income
  final bool isIncome;

  _TransactionWrapper({
    required this.id,
    required this.object,
    required this.isIncome,
  });
}
