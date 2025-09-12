import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/screens/settings_screen.dart';
import 'package:personal_finance_tracker/screens/statistics_screen.dart';
import 'dashboard_screen.dart';
import 'models/transaction.dart';
import 'services/transaction_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // Load transactions from database
  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await _transactionService.getAllTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add a new transaction
  Future<void> _addTransaction(
    String title,
    double amount,
    String category,
    bool isExpense,
  ) async {
    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
      isExpense: isExpense,
    );

    try {
      await _transactionService.addTransaction(newTransaction);
      await _loadTransactions(); // Reload to show the new transaction

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add transaction')),
        );
      }
    }
  }

  // Delete a transaction
  Future<void> _deleteTransaction(String id) async {
    try {
      await _transactionService.deleteTransaction(id);
      await _loadTransactions(); // Reload to update the list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete transaction')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> screens = [
      DashboardScreen(
        transactions: _transactions,
        onAddTransaction: _addTransaction,
        onDeleteTransaction: _deleteTransaction,
        onRefresh: _loadTransactions,
      ),
      StatisticsScreen(transactions: _transactions),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
