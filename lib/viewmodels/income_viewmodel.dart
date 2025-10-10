import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/isar_service.dart';
import '../data/models/income.dart';
import '../main.dart';

final incomeViewModelProvider =
StateNotifierProvider<IncomeViewModel, List<Income>>((ref) {
  final isarService = ref.read(isarServiceProvider);
  return IncomeViewModel(isarService);
});

class IncomeViewModel extends StateNotifier<List<Income>> {
  final IsarService _isarService;

  IncomeViewModel(this._isarService) : super([]);

  Future<void> addIncome(Income income) async {
    await _isarService.addIncome(income);
    state = [...state, income];
  }

  Future<void> loadIncomes() async {
    final incomes = await _isarService.getIncomes();
    state = incomes;
  }

  Future<void> deleteIncome(int id) async {
    await _isarService.deleteIncome(id);
    await loadIncomes();
  }

  Future<void> updateIncome(Income income) async {
    await _isarService.addIncome(income); // same as put
    await loadIncomes();
  }

  // 🧮 Optional helper: total income this month
  double get totalIncome {
    return state.fold(0, (sum, i) => sum + i.amount);
  }
}
