import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models/category.dart';
import '../data/models/expense.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/expense_viewmodel.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  Expense? _editingExpense;

  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;

  bool get isEditing => _editingExpense != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();

    // Load only expense categories
    Future.microtask(() {
      ref.read(categoryViewModelProvider.notifier).loadCategories(CategoryType.expense);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Expense && _editingExpense == null) {
      _editingExpense = args;

      _titleController.text = _editingExpense!.title;
      _amountController.text = _editingExpense!.amount.toString();
      _selectedDate = _editingExpense!.date;
      _selectedCategory = _editingExpense!.category.value;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _clearForm() {
    setState(() {
      _titleController.clear();
      _amountController.clear();
      _selectedDate = DateTime.now();
      _selectedCategory = null;
    });
  }

  void _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || _selectedCategory == null) {
      setState(() {}); // trigger UI errors
      return;
    }

    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text.trim());

    final expenseVM = ref.read(expenseViewModelProvider.notifier);

    if (isEditing) {
      _editingExpense!
        ..title = title
        ..amount = amount
        ..date = _selectedDate
        ..category.value = _selectedCategory;

      await expenseVM.updateExpense(_editingExpense!);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Expense "$title" updated!'), backgroundColor: Colors.green),
      );
    } else {
      final newExpense = Expense()
        ..title = title
        ..amount = amount
        ..date = _selectedDate
        ..category.value = _selectedCategory;

      await expenseVM.addExpense(newExpense);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Expense "$title" added!'), backgroundColor: Colors.green),
      );

      _clearForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryViewModelProvider)
        .where((cat) => cat.type == CategoryType.expense)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (val) => val == null || val.isEmpty ? 'Enter title' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter amount';
                      final n = double.tryParse(val);
                      if (n == null || n <= 0) return 'Enter valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Category:', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (categories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('No categories available', style: TextStyle(color: Colors.red)),
                    ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: categories.map((cat) {
                      return ChoiceChip(
                        label: Text(cat.name),
                        selected: _selectedCategory == cat,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      );
                    }).toList(),
                  ),
                  if (_selectedCategory == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Please select a category', style: TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: Text(isEditing ? 'Update Expense' : 'Add Expense'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
