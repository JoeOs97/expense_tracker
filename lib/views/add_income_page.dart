import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/income_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../data/models/income.dart';
import '../data/models/category.dart';

class AddIncomePage extends ConsumerStatefulWidget {
  const AddIncomePage({super.key});

  @override
  ConsumerState<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends ConsumerState<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  Income? editingIncome;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  late final isEditing = editingIncome != null;

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
    if (args != null && args is Income) {
      editingIncome = args;
      _titleController.text = editingIncome!.note!;
      _amountController.text = editingIncome!.amount.toString();
      _selectedDate = editingIncome!.date;
      _selectedCategory = editingIncome!.category.value;
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
    // Only show income categories
    final categories = ref.watch(categoryViewModelProvider)
        .where((cat) => cat.type == CategoryType.income)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Income', style: TextStyle(color: Colors.white)),
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
                    mainAxisSize: MainAxisSize.min,
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
                            'No income categories available',
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

                      // ✅ Add Income Button
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
                              setState(() {});
                              return;
                            }

                            final title = _titleController.text.trim();
                            final amount = double.parse(
                              _amountController.text.trim(),
                            );

                            if (isEditing) {
                              editingIncome!
                                ..note = title
                                ..amount = amount
                                ..date = _selectedDate
                                ..category.value = _selectedCategory;

                              await ref
                                  .read(incomeViewModelProvider.notifier)
                                  .updateIncome(editingIncome!);

                              if (!mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ Income "$title" updated successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              final newIncome = Income()
                                ..note = title
                                ..amount = amount
                                ..date = _selectedDate
                                ..category.value = _selectedCategory;

                              await ref
                                  .read(incomeViewModelProvider.notifier)
                                  .addIncome(newIncome);

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ Income "$title" added successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _clearForm();
                            }
                          },
                          child: Text(
                            isEditing ? 'Update Income' : 'Add Income',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ✅ Clear Form Button
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
                            'Add Another Income',
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
