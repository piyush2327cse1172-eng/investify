import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class AddTransactionDialog extends StatefulWidget {
  final VoidCallback onTransactionAdded;

  const AddTransactionDialog({super.key, required this.onTransactionAdded});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  final List<String> _categories = ['Food', 'Transport', 'Entertainment', 'Shopping', 'Bills'];

  double _calculateRoundUp(double amount) {
    // Round up to next multiple of 5 (like ₹64 → ₹65)
    final roundedUp = ((amount / 5).ceil() * 5).toDouble();
    return roundedUp - amount;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Transaction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Transaction Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
                helperText: 'e.g., ₹64 will be rounded to ₹65 (₹1 invested)',
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to show round-up preview
              },
            ),
            if (_amountController.text.isNotEmpty && double.tryParse(_amountController.text) != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: () {
                  final amount = double.parse(_amountController.text);
                  final roundUp = _calculateRoundUp(amount);
                  final total = amount + roundUp;
                  return Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.blue[600], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '₹${amount.toStringAsFixed(0)} → ₹${total.toStringAsFixed(0)} (₹${roundUp.toStringAsFixed(0)} invested)',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  );
                }(),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _addTransaction() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final roundUpAmount = _calculateRoundUp(amount);
    final roundedTotal = amount + roundUpAmount;

    final transaction = Transaction(
      title: _titleController.text,
      amount: amount,
      roundUpAmount: roundUpAmount,
      category: _selectedCategory,
      date: DateTime.now(),
      type: 'expense',
    );

    await DatabaseService.insertTransaction(transaction);
    widget.onTransactionAdded();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('₹${amount.toStringAsFixed(0)} → ₹${roundedTotal.toStringAsFixed(0)} | ₹${roundUpAmount.toStringAsFixed(0)} invested!'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}