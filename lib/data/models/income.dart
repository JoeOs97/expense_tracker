import 'package:isar/isar.dart';
import 'category.dart';

part 'income.g.dart';

@collection
class Income {
  Id id = Isar.autoIncrement;

  late double amount;
  late DateTime date;
  final category = IsarLink<Category>();
  String? note;
}
