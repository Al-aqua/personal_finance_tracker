import 'package:flutter/material.dart';
import '../models/transaction.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const StatisticsScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final totalIncome = transactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final totalExpenses = transactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final balance = totalIncome - totalExpenses;

    // Group expenses by category
    final Map<String, double> expensesByCategory = {};
    for (var tx in transactions.where((tx) => tx.isExpense)) {
      expensesByCategory[tx.category] =
          (expensesByCategory[tx.category] ?? 0) + tx.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Income',
                    '\$${totalIncome.toStringAsFixed(2)}',
                    Colors.green,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Expenses',
                    '\$${totalExpenses.toStringAsFixed(2)}',
                    Colors.red,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildStatCard(
              'Net Balance',
              '\$${balance.toStringAsFixed(2)}',
              balance >= 0 ? Colors.green : Colors.red,
              balance >= 0 ? Icons.trending_up : Icons.trending_down,
            ),
            const SizedBox(height: 32),

            // Expenses by Category
            const Text(
              'Expenses by Category',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (expensesByCategory.isEmpty)
              const Center(
                child: Text(
                  'No expenses to show',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...expensesByCategory.entries.map((entry) {
                final percentage = (entry.value / totalExpenses * 100);
                return _buildCategoryRow(entry.key, entry.value, percentage);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String category, double amount, double percentage) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${percentage.toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
