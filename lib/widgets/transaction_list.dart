import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this package with: flutter pub add intl
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(String) onDeleteTransaction;
  final Function(Transaction)? onTransactionTap;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.onDeleteTransaction,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No transactions yet!',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (ctx, index) {
        return TransactionCard(
          transaction: transactions[index],
          onDelete: onDeleteTransaction,
          onTap: onTransactionTap,
        );
      },
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final Function(String) onDelete;
  final Function(Transaction)? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      child: ListTile(
        onTap: onTap != null ? () => onTap!(transaction) : null,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: transaction.isExpense
              ? Colors.red.shade100
              : Colors.green.shade100,
          child: Icon(
            getCategoryIcon(transaction.category),
            color: transaction.isExpense ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction.category} • ${DateFormat.yMMMd().format(transaction.date)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.isExpense ? Colors.red : Colors.green,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () => onDelete(transaction.id),
            ),
          ],
        ),
      ),
    );
  }

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'utilities':
        return Icons.receipt;
      case 'salary':
        return Icons.work;
      case 'gift':
        return Icons.card_giftcard;
      default:
        return Icons.attach_money;
    }
  }
}
