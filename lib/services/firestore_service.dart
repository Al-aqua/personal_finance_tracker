import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get user's transactions collection reference
  CollectionReference? get _userTransactionsCollection {
    if (_userId == null) return null;
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions');
  }

  // Create or update user profile
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('User profile created/updated: $email');
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  // Add transaction to Firestore
  Future<void> addTransaction(Transaction transaction) async {
    if (_userTransactionsCollection == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _userTransactionsCollection!.doc(transaction.id).set({
        'title': transaction.title,
        'amount': transaction.amount,
        'date': Timestamp.fromDate(transaction.date),
        'category': transaction.category,
        'isExpense': transaction.isExpense,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Transaction added to Firestore: ${transaction.title}');
    } catch (e) {
      debugPrint('Error adding transaction to Firestore: $e');
      rethrow;
    }
  }

  // Get all transactions from Firestore
  Future<List<Transaction>> getAllTransactions() async {
    if (_userTransactionsCollection == null) {
      throw Exception('User not authenticated');
    }

    try {
      final querySnapshot = await _userTransactionsCollection!
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Transaction(
          id: doc.id,
          title: data['title'],
          amount: data['amount'].toDouble(),
          date: (data['date'] as Timestamp).toDate(),
          category: data['category'],
          isExpense: data['isExpense'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting transactions from Firestore: $e');
      rethrow;
    }
  }

  // Get real-time transaction stream
  Stream<List<Transaction>> getTransactionsStream() {
    if (_userTransactionsCollection == null) {
      return Stream.empty();
    }

    return _userTransactionsCollection!
        .orderBy('date', descending: true)
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Transaction(
              id: doc.id,
              title: data['title'],
              amount: data['amount'].toDouble(),
              date: (data['date'] as Timestamp).toDate(),
              category: data['category'],
              isExpense: data['isExpense'],
            );
          }).toList();
        });
  }

  // Update transaction in Firestore
  Future<void> updateTransaction(Transaction transaction) async {
    if (_userTransactionsCollection == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _userTransactionsCollection!.doc(transaction.id).update({
        'title': transaction.title,
        'amount': transaction.amount,
        'date': Timestamp.fromDate(transaction.date),
        'category': transaction.category,
        'isExpense': transaction.isExpense,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Transaction updated in Firestore: ${transaction.title}');
    } catch (e) {
      debugPrint('Error updating transaction in Firestore: $e');
      rethrow;
    }
  }

  // Delete transaction from Firestore
  Future<void> deleteTransaction(String transactionId) async {
    if (_userTransactionsCollection == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _userTransactionsCollection!.doc(transactionId).delete();
      debugPrint('Transaction deleted from Firestore: $transactionId');
    } catch (e) {
      debugPrint('Error deleting transaction from Firestore: $e');
      rethrow;
    }
  }

  // Sync local transactions to Firestore
  Future<void> syncLocalTransactionsToFirestore(
    List<Transaction> localTransactions,
  ) async {
    if (_userTransactionsCollection == null) return;

    try {
      final batch = _firestore.batch();

      for (final transaction in localTransactions) {
        final docRef = _userTransactionsCollection!.doc(transaction.id);
        batch.set(docRef, {
          'title': transaction.title,
          'amount': transaction.amount,
          'date': Timestamp.fromDate(transaction.date),
          'category': transaction.category,
          'isExpense': transaction.isExpense,
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      debugPrint(
        'Local transactions synced to Firestore: ${localTransactions.length} items',
      );
    } catch (e) {
      debugPrint('Error syncing local transactions to Firestore: $e');
      rethrow;
    }
  }
}
