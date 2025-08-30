import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/models/transaction.dart';
import 'package:personal_finance_tracker/widgets/balance_overview_card.dart';
import 'package:personal_finance_tracker/widgets/grouped_transaction_list.dart';
import 'package:personal_finance_tracker/widgets/summary_card.dart';
import 'package:personal_finance_tracker/widgets/add_transaction_form.dart';

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  String? _selectedCategory;

  // Add this method to the class
  List<Transaction> get _filteredTransactions {
    var filtered = _transactions;

    if (_selectedCategory != null) {
      filtered = filtered
          .where((tx) => tx.category == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (tx) => tx.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  String _searchQuery = '';

  // Sample transaction data
  final List<Transaction> _transactions = [
    Transaction(
      id: 't1',
      title: 'Grocery Shopping',
      amount: 45.99,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Food',
      isExpense: true,
    ),
    Transaction(
      id: 't2',
      title: 'Monthly Salary',
      amount: 1500.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: 'Salary',
      isExpense: false,
    ),
    Transaction(
      id: 't3',
      title: 'New Headphones',
      amount: 99.99,
      date: DateTime.now().subtract(const Duration(days: 5)),
      category: 'Shopping',
      isExpense: true,
    ),
    Transaction(
      id: 't4',
      title: 'Restaurant Dinner',
      amount: 35.50,
      date: DateTime.now().subtract(const Duration(days: 7)),
      category: 'Food',
      isExpense: true,
    ),
  ];

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
  }

  void _addTransaction(
    String title,
    double amount,
    String category,
    bool isExpense,
  ) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
      isExpense: isExpense,
    );

    setState(() {
      _transactions.add(newTx);
    });
  }

  void _startAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return AddTransactionForm(onAddTransaction: _addTransaction);
      },
    );
  }

  // Calculate totals for summary cards
  double get _totalIncome {
    return _transactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get _totalExpenses {
    return _transactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get _balance {
    return _totalIncome - _totalExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
            BalanceOverviewCard(balance: _balance),
            const SizedBox(height: 24),

            // Income & Expenses Row
            const Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Income and Expense cards
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Income',
                    amount: _totalIncome,
                    icon: Icons.arrow_upward,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'Expenses',
                    amount: _totalExpenses,
                    icon: Icons.arrow_downward,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            // Recent Transactions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String?>(
                  hint: const Text('All Categories'),
                  value: _selectedCategory,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...{..._transactions.map((tx) => tx.category)}.map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Transaction List
            SizedBox(
              height: 400, // Fixed height for the list
              child: GroupedTransactionList(
                transactions: _filteredTransactions,
                onDeleteTransaction: _deleteTransaction,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddTransaction(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
