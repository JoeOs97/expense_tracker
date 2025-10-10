import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'data/database/isar_service.dart';
import 'data/models/expense.dart';
import 'data/models/category.dart';
import 'data/models/income.dart';

// Create a global provider for IsarService
final isarServiceProvider = Provider<IsarService>((ref) {
  throw UnimplementedError('IsarService not initialized yet');
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Open Isar manually
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [ExpenseSchema, CategorySchema , IncomeSchema,],
    directory: dir.path,
  );

  final isarService = IsarService(isar);
  await isarService.seedPresetCategories();

  // ✅ Inject initialized IsarService into Riverpod
  runApp(
    ProviderScope(
      overrides: [
        isarServiceProvider.overrideWithValue(isarService),
      ],
      child: App(),
    ),
  );
}
