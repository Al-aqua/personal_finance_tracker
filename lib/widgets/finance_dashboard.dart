import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/widgets/balance_overview_card.dart';
import 'package:personal_finance_tracker/widgets/savings_goal_card.dart';
import 'package:personal_finance_tracker/widgets/summary_card.dart';

class FinanceDashboard extends StatelessWidget {
  const FinanceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          const Text(
            'My Balance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Balance Card
          BalanceOverviewCard(),
          const SizedBox(height: 24),

          // Income & Expenses Row
          const Text(
            'Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const SavingsGoalCard(),
          const SizedBox(height: 24),

          // Income and Expense cards
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Income',
                  amount: 1250.00,
                  icon: Icons.arrow_upward,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryCard(
                  title: 'Expenses',
                  amount: 850.00,
                  icon: Icons.arrow_downward,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Transactions Header
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Placeholder for transactions (will implement in Lab 3)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Your transactions will appear here',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
