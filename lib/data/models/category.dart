import 'package:isar/isar.dart';

part 'category.g.dart';

@Collection()
class Category{
  Id id = Isar.autoIncrement;
  late String name;
  @enumerated
  late CategoryType type; // expense or income
}
enum CategoryType {expense , income}