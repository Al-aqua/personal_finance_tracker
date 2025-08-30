import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTransactionForm extends StatefulWidget {
  final Function(String, double, String, bool) onAddTransaction;

  const AddTransactionForm({super.key, required this.onAddTransaction});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text inputs
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  // Form state variables
  String _selectedCategory = 'Food';
  bool _isExpense = true;

  // Available categories
  final List<String> _categories = [
    'Food',
    'Shopping',
    'Transport',
    'Entertainment',
    'Utilities',
    'Salary',
    'Gift',
    'Other',
  ];

  @override
  void dispose() {
    // Clean up controllers
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Method to submit the form
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return; // Form is not valid
    }

    final title = _titleController.text;
    final amount = double.parse(_amountController.text);

    widget.onAddTransaction(title, amount, _selectedCategory, _isExpense);

    Navigator.of(context).pop(); // Close the form
  }

  void _clearForm() {
    _titleController.clear();
    _amountController.clear();
    setState(() {
      _selectedCategory = 'Food';
      _isExpense = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form title
            const Text(
              'Add New Transaction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Title input
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Transaction Title',
                hintText: 'e.g., Grocery Shopping',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                if (value.length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount input
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                // Format the input as currency
                if (value.isNotEmpty) {
                  final amount = double.tryParse(value);
                  if (amount != null) {
                    final formatted = NumberFormat.currency(
                      symbol: '',
                    ).format(amount);
                    // Update controller without triggering onChanged again
                  }
                }
              },
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Income/Expense toggle
            Card(
              child: SwitchListTile(
                title: Text(_isExpense ? 'Expense' : 'Income'),
                subtitle: Text(
                  _isExpense ? 'Money going out' : 'Money coming in',
                ),
                value: _isExpense,
                onChanged: (value) {
                  setState(() {
                    _isExpense = value;
                  });
                },
                secondary: Icon(
                  _isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                  color: _isExpense ? Colors.red : Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Add Transaction',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _clearForm,
              child: const Text('Clear Form'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
