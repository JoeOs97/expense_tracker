import 'package:expense_tracker/data/models/income.dart';
import 'package:isar/isar.dart';
import '../models/expense.dart';
import '../models/category.dart';

class IsarService {
  final Isar isar;
  IsarService(this.isar);

  // Preset Categories
  static final List<Category> presetCategories = [
    Category()..name = 'Food'..type = CategoryType.expense,
    Category()..name = 'Transport'..type = CategoryType.expense,
    Category()..name = 'Utilities'..type = CategoryType.expense,
    Category()..name = 'Shopping'..type = CategoryType.expense,
    Category()..name = 'Entertainment'..type = CategoryType.expense,
    Category()..name = 'Health'..type = CategoryType.expense,
    Category()..name = 'Education'..type = CategoryType.expense,
    Category()..name = 'Housing'..type = CategoryType.expense,
    Category()..name = 'Insurance'..type = CategoryType.expense,
    Category()..name = 'Travel'..type = CategoryType.expense,
    Category()..name = 'Gifts'..type = CategoryType.expense,
    Category()..name = 'Other'..type = CategoryType.expense,
    // INCOME CATEGORIES
    Category()..name = 'Salary'..type = CategoryType.income,
    Category()..name = 'Freelance'..type = CategoryType.income,
    Category()..name = 'Investments'..type = CategoryType.income,
    Category()..name = 'Gift Income'..type = CategoryType.income,
    Category()..name = 'Other Income'..type = CategoryType.income,
  ];

  Future<void> seedPresetCategories() async {
    final existingCategories = await isar.categorys.where().findAll();
    final existingNames = existingCategories.map((c) => c.name).toSet();

    // Only insert categories that don't exist yet
    final newCategories = presetCategories
        .where((c) => !existingNames.contains(c.name))
        .toList();

    if (newCategories.isNotEmpty) {
      await isar.writeTxn(() async {
        await isar.categorys.putAll(newCategories);
      });
    }
  }
  // In IsarService
  // filtering categories depending on expense or income
  Future<List<Category>> getExpenseCategories() async {
    return await isar.categorys
        .filter()
        .typeEqualTo(CategoryType.expense)
        .findAll();
  }

  Future<List<Category>> getIncomeCategories() async {
    return await isar.categorys
        .filter()
        .typeEqualTo(CategoryType.income)
        .findAll();
  }

  Future<void> addExpense(Expense expense) async {
    await isar.writeTxn(() async {
      await isar.expenses.put(expense);
      await expense.category.save();
    });
  }

  Future<List<Expense>> getExpenses() async {
    return await isar.expenses.where().findAll();
  }

  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() async {
      // Delete by ID using the collection
      await isar.expenses.delete(id);
    });
  }
  Future<void> addIncome(Income income) async {
    await isar.writeTxn(() async {
      await isar.incomes.put(income);
      await income.category.save();
    });
  }

  Future<List<Income>> getIncomes() async {
    return await isar.incomes.where().findAll();
  }

  Future<void> deleteIncome(int id) async {
    await isar.writeTxn(() async {
      await isar.incomes.delete(id);
    });
  }



}
