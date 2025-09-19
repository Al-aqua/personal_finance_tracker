import 'package:flutter/foundation.dart';
import '../helpers/database_helper.dart';
import '../models/transaction.dart';
import 'firestore_service.dart';

class TransactionService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isOnline = true; // You can implement proper connectivity checking

  // Get all transactions (with offline support)
  Future<List<Transaction>> getAllTransactions() async {
    try {
      if (_isOnline) {
        // Try to get from Firestore first
        final firestoreTransactions = await _firestoreService
            .getAllTransactions();

        // Update local database with Firestore data
        for (final transaction in firestoreTransactions) {
          await _databaseHelper.insertTransaction(transaction);
        }

        return firestoreTransactions;
      } else {
        // Fallback to local database
        return await _databaseHelper.getAllTransactions();
      }
    } catch (e) {
      debugPrint(
        'Error getting transactions from Firestore, falling back to local: $e',
      );
      // Fallback to local database if Firestore fails
      return await _databaseHelper.getAllTransactions();
    }
  }

  // Get real-time transaction stream
  Stream<List<Transaction>> getTransactionsStream() {
    try {
      return _firestoreService.getTransactionsStream();
    } catch (e) {
      debugPrint('Error getting transaction stream: $e');
      return Stream.empty();
    }
  }

  // Add a new transaction (sync to both local and cloud)
  Future<void> addTransaction(Transaction transaction) async {
    try {
      // Always save locally first
      await _databaseHelper.insertTransaction(transaction);

      // Try to sync to Firestore
      if (_isOnline) {
        await _firestoreService.addTransaction(transaction);
      }
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      // Transaction is saved locally even if cloud sync fails
      rethrow;
    }
  }

  // Update an existing transaction
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      // Update locally
      await _databaseHelper.updateTransaction(transaction);

      // Try to sync to Firestore
      if (_isOnline) {
        await _firestoreService.updateTransaction(transaction);
      }
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    try {
      // Delete locally
      await _databaseHelper.deleteTransaction(id);

      // Try to sync to Firestore
      if (_isOnline) {
        await _firestoreService.deleteTransaction(id);
      }
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Sync local data to Firestore (useful when going online)
  Future<void> syncToCloud() async {
    try {
      final localTransactions = await _databaseHelper.getAllTransactions();
      await _firestoreService.syncLocalTransactionsToFirestore(
        localTransactions,
      );
    } catch (e) {
      debugPrint('Error syncing to cloud: $e');
      rethrow;
    }
  }

  // Calculate total income (from local data for speed)
  Future<double> getTotalIncome() async {
    final transactions = await _databaseHelper.getAllTransactions();
    double total = 0.0;
    for (var tx in transactions) {
      if (!tx.isExpense) {
        total += tx.amount;
      }
    }
    return total;
  }

  // Calculate total expenses (from local data for speed)
  Future<double> getTotalExpenses() async {
    final transactions = await _databaseHelper.getAllTransactions();
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
