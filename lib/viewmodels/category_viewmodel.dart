import 'package:expense_tracker/data/database/isar_service.dart';
import 'package:expense_tracker/data/models/category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';

class CategoryViewModel extends StateNotifier<List<Category>> {
  final IsarService _isarService;

  CategoryViewModel(this._isarService) : super([]) {
    _init();
  }

  Future<void> _init() async {
    await _isarService.seedPresetCategories();

    // ⚡ Default to loading expense categories so AddExpensePage works
    await loadCategories(CategoryType.expense);
    await loadCategories(CategoryType.income);
  }



  // ⚡ Minimal change: pass type
  Future<void> loadCategories(CategoryType type) async {
    final categories = (type == CategoryType.expense)
        ? await _isarService.getExpenseCategories()
        : await _isarService.getIncomeCategories();

    // Append to state without duplicating
    state = [
      ...state.where((c) => c.type != type), // remove old of same type
      ...categories,
    ];
  }


}

final categoryViewModelProvider =
StateNotifierProvider<CategoryViewModel, List<Category>>((ref) {
  final isarService = ref.read(isarServiceProvider);
  return CategoryViewModel(isarService);
});
