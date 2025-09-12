import 'package:personal_finance_tracker/helpers/database_helper.dart';
import 'package:personal_finance_tracker/models/transaction.dart';

class TransactionService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Get all transactions
  Future<List<Transaction>> getAllTransactions() async {
    return await _databaseHelper.getAllTransactions();
  }

  // Add a new transaction
  Future<void> addTransaction(Transaction transaction) async {
    await _databaseHelper.insertTransaction(transaction);
  }

  // Update an existing transaction
  Future<void> updateTransaction(Transaction transaction) async {
    await _databaseHelper.updateTransaction(transaction);
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    await _databaseHelper.deleteTransaction(id);
  }

  // Get transactions by category
  Future<List<Transaction>> getTransactionsByCategory(String category) async {
    return await _databaseHelper.getTransactionsByCategory(category);
  }

  // Calculate total income
  Future<double> getTotalIncome() async {
    final transactions = await getAllTransactions();
    double total = 0.0;
    for (var tx in transactions) {
      if (!tx.isExpense) {
        total += tx.amount;
      }
    }
    return total;
  }

  // Calculate total expenses
  Future<double> getTotalExpenses() async {
    final transactions = await getAllTransactions();
    double total = 0.0;
    for (var tx in transactions) {
      if (tx.isExpense) {
        total += tx.amount;
      }
    }
    return total;
  }

  // Calculate balance
  Future<double> getBalance() async {
    final income = await getTotalIncome();
    final expenses = await getTotalExpenses();
    return income - expenses;
  }
}
