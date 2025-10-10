import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../data/models/expense.dart';
import '../data/models/category.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  Expense? editingExpense;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  late final isEditing = editingExpense != null;

  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;

  void _clearForm() {
    setState(() {
      _titleController.clear();
      _amountController.clear();
      _selectedDate = DateTime.now();
      _selectedCategory = null;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Expense) {
      editingExpense = args;

      // Populate form fields
      _titleController.text = editingExpense!.title;
      _amountController.text = editingExpense!.amount.toString();
      _selectedDate = editingExpense!.date;
      _selectedCategory = editingExpense!.category.value;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // 👈 makes the card fit content
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter title'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Amount'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter amount';
                          }
                          final n = num.tryParse(value);
                          if (n == null || n <= 0) {
                            return 'Enter valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Select Category:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (categories.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'No categories available',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: categories.map((category) {
                          return ChoiceChip(
                            label: Text(category.name),
                            selected: _selectedCategory == category,
                            onSelected: (_) {
                              setState(() => _selectedCategory = category);
                            },
                          );
                        }).toList(),
                      ),
                      if (_selectedCategory == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Please select a category',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // ✅ Add Expense Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.teal,
                          ),
                          onPressed: () async {
                            final formValid =
                                _formKey.currentState?.validate() ?? false;
                            if (!formValid || _selectedCategory == null) {
                              setState(() {}); // show errors
                              return;
                            }

                            final title = _titleController.text.trim();
                            final amount = double.parse(
                              _amountController.text.trim(),
                            );

                            if (isEditing) {
                              // update existing expense
                              editingExpense!
                                ..title = title
                                ..amount = amount
                                ..date = _selectedDate
                                ..category.value = _selectedCategory;

                              await ref
                                  .read(expenseViewModelProvider.notifier)
                                  .updateExpense(editingExpense!);

                              if (!mounted) return;
                              Navigator.pop(context); // go back after edit
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ Expense "$title" updated successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              // add new expense
                              final newExpense = Expense()
                                ..title = title
                                ..amount = amount
                                ..date = _selectedDate
                                ..category.value = _selectedCategory;

                              await ref
                                  .read(expenseViewModelProvider.notifier)
                                  .addExpense(newExpense);

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ Expense "$title" added successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _clearForm();
                            }
                          },
                          child: Text(
                            isEditing ? 'Update Expense' : 'Add Expense',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ✅ Add Another Expense Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                              color: Colors.teal,
                              width: 1.2,
                            ),
                          ),
                          onPressed: _clearForm,
                          child: const Text(
                            'Add Another Expense',
                            style: TextStyle(color: Colors.teal, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
