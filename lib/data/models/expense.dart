import 'package:isar/isar.dart';

import 'category.dart';

part 'expense.g.dart'; // exact filename matching current file

@Collection()
class Expense {
  Id id = Isar.autoIncrement;

  late String title;
  late double amount;
  late DateTime date;


  final category = IsarLink<Category>();
}
