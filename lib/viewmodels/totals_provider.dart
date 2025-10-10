import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'expense_viewmodel.dart';
import 'income_viewmodel.dart';

/// ✅ Calculates total income
final totalIncomeProvider = Provider<double>((ref) {
  final incomes = ref.watch(incomeViewModelProvider);
  return incomes.fold(0, (sum, i) => sum + i.amount);
});

/// ✅ Calculates total expenses
final totalExpensesProvider = Provider<double>((ref) {
  final expenses = ref.watch(expenseViewModelProvider);
  return expenses.fold(0, (sum, e) => sum + e.amount);
});

/// ✅ Calculates balance = income - expenses
final totalBalanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expenses = ref.watch(totalExpensesProvider);
  return income - expenses;
});
