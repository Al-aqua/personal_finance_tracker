import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_tracker/widgets/transaction_list.dart';
import '../models/transaction.dart';

class GroupedTransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(String) onDeleteTransaction;

  const GroupedTransactionList({
    super.key,
    required this.transactions,
    required this.onDeleteTransaction,
  });

  @override
  Widget build(BuildContext context) {
    // Sort transactions by date (newest first)
    final sortedTransactions = List.of(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group transactions by date
    final Map<String, List<Transaction>> groupedTransactions = {};

    for (var tx in sortedTransactions) {
      final dateKey = DateFormat.yMMMd().format(tx.date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(tx);
    }

    // Convert to list of date-transactions pairs
    final groupList = groupedTransactions.entries.toList();

    return ListView.builder(
      itemCount: groupList.length,
      itemBuilder: (ctx, index) {
        final dateKey = groupList[index].key;
        final dateTransactions = groupList[index].value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                dateKey,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            ...dateTransactions.map((tx) {
              return TransactionCard(
                transaction: tx,
                onDelete: onDeleteTransaction,
              );
            }).toList(),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
