import 'package:expense_tracker/data/database/isar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../data/models/expense.dart';
import '../main.dart';

final expenseViewModelProvider =
StateNotifierProvider<ExpenseViewModel, List<Expense>>((ref) {
  final isarService = ref.read(isarServiceProvider);
  return ExpenseViewModel(isarService);
});

class ExpenseViewModel extends StateNotifier<List<Expense>> {
  final IsarService _isarService;

  ExpenseViewModel(this._isarService) : super([]);

  Future<void> addExpense(Expense expense) async {
    await _isarService.addExpense(expense);
    state = [...state, expense];
  }

  Future<void> loadExpenses() async {
    final expenses = await _isarService.getExpenses();
    state = expenses;
  }

  Future<void> deleteExpense(int id) async {
    await _isarService.deleteExpense(id);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await _isarService.addExpense(expense);
    await loadExpenses();
  }

  // 👇 Add this
  double get totalExpenses {
    if (state.isEmpty) return 0;
    return state.fold(0, (sum, e) => sum + e.amount);
  }
}
