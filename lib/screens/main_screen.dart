import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/currency_converter_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/statistics_screen.dart';
import '../dashboard_screen.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../services/firestore_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final TransactionService _transactionService = TransactionService();
  final FirestoreService _firestoreService = FirestoreService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _setupTransactionStream();
  }

  // Initialize user profile in Firestore
  Future<void> _initializeUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestoreService.createUserProfile(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
        );
      }
    } catch (e) {
      debugPrint('Error initializing user: $e');
    }
  }

  // Set up real-time transaction stream
  void _setupTransactionStream() {
    _transactionService.getTransactionsStream().listen(
      (transactions) {
        if (mounted) {
          setState(() {
            _transactions = transactions;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        debugPrint('Transaction stream error: $error');
        // Fallback to loading from local database
        _loadTransactionsFromLocal();
      },
    );
  }

  // Fallback to local data
  Future<void> _loadTransactionsFromLocal() async {
    try {
      final transactions = await _transactionService.getAllTransactions();
      if (mounted) {
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading transactions from local: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  // Refresh data manually
  Future<void> _refreshData() async {
    try {
      await _transactionService.syncToCloud();
      // The stream will automatically update the UI
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your data...'),
            ],
          ),
        ),
      );
    }

    final List<Widget> screens = [
      DashboardScreen(
        transactions: _transactions,
        onAddTransaction: _addTransaction,
        onDeleteTransaction: _deleteTransaction,
        onRefresh: _refreshData,
      ),
      StatisticsScreen(transactions: _transactions),
      const CurrencyConverterScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Show all tabs
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
            icon: Icon(Icons.currency_exchange),
            label: 'Convert',
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
