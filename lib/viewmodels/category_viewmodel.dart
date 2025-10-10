import 'package:expense_tracker/data/database/isar_service.dart';
import 'package:expense_tracker/data/models/category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';

class CategoryViewModel extends StateNotifier<List<Category>> {
  final IsarService _isarService;

  CategoryViewModel(this._isarService) : super([]) {
    _init(); // call initialization logic when the viewmodel is created
  }

  Future<void> _init() async {
    // 1️⃣ Seed preset categories if this is the first run
    await _isarService.seedPresetCategories();

    // 2️⃣ Then load all categories from Isar
    await loadCategories();
  }

  Future<void> loadCategories() async {
    final categories = await _isarService.getCategories();
    state = categories;
  }

  Future<void> addCategory(Category category) async {
    await _isarService.addCategory(category);
    await loadCategories();
  }
}

final categoryViewModelProvider =
StateNotifierProvider<CategoryViewModel, List<Category>>((ref) {
  final isarService = ref.read(isarServiceProvider);
  return CategoryViewModel(isarService);
});
