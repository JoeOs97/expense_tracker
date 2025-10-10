import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/expense.dart';
import '../data/models/income.dart';

class TransactionCard extends StatelessWidget {
  final dynamic transaction; // can be Expense or Income
  final bool isIncome;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.isIncome,
    this.onUpdate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = isIncome
        ? (transaction as Income).note
        : (transaction as Expense).title;

    final amount = transaction.amount;
    final date = transaction.date;

    final amountColor = isIncome ? Colors.greenAccent : Colors.redAccent;
    final icon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isIncome ? Colors.green : Colors.red,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title ?? 'Transaction',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${isIncome ? '+' : '-'}${amount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "${_getCategoryName(transaction)} • ${_formatDate(date)}",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),

            ],
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Time or short date
              Text(
                DateFormat('hh:mm a').format(date),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),

              // Row of buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                    onPressed: onUpdate,
                    tooltip: 'Edit Transaction',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Delete Transaction',
                  ),
                ],
              ),

              // Small tag (Income or Expense)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isIncome ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isIncome ? "Income" : "Expense",
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _getCategoryName(dynamic transaction) {
    try {
      if (transaction is Expense) {
        return transaction.category.value?.name ?? 'Uncategorized';
      }
      if (transaction is Income) {
        // For Income, you mentioned the name field is "note"
        return transaction.category.value?.name ?? 'Income';
      }
      if (transaction.category is String) {
        return transaction.category;
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }
}
