import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models/category.dart';
import '../data/models/income.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';

class AddIncomePage extends ConsumerStatefulWidget {
  const AddIncomePage({super.key});

  @override
  ConsumerState<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends ConsumerState<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  Income? _editingIncome;
  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;

  bool get isEditing => _editingIncome != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();

    // Load only income categories
    Future.microtask(() {
      ref.read(categoryViewModelProvider.notifier)
          .loadCategories(CategoryType.income);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Income && _editingIncome == null) {
      _editingIncome = args;

      _titleController.text = _editingIncome!.note ?? '';
      _amountController.text = _editingIncome!.amount.toString();
      _selectedDate = _editingIncome!.date;
      _selectedCategory = _editingIncome!.category.value;
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

    if (picked != null && picked != _selectedDate) {
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
      setState(() {}); // show errors
      return;
    }

    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final incomeVM = ref.read(incomeViewModelProvider.notifier);

    if (isEditing) {
      _editingIncome!
        ..note = title
        ..amount = amount
        ..date = _selectedDate
        ..category.value = _selectedCategory;

      await incomeVM.updateIncome(_editingIncome!);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Income "$title" updated!'), backgroundColor: Colors.green),
      );
    } else {
      final newIncome = Income()
        ..note = title
        ..amount = amount
        ..date = _selectedDate
        ..category.value = _selectedCategory;

      await incomeVM.addIncome(newIncome);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Income "$title" added!'), backgroundColor: Colors.green),
      );

      _clearForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryViewModelProvider)
        .where((cat) => cat.type == CategoryType.income)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Income' : 'Add Income'),
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
                      child: Text('No income categories available', style: TextStyle(color: Colors.red)),
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
                      child: Text(isEditing ? 'Update Income' : 'Add Income'),
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
