import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart'
    hide Transaction; // to avoid conflict with Transaction class
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Singleton pattern - ensures only one database connection
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    // Get the path to store the database
    String path = join(await getDatabasesPath(), 'finance_tracker.db');

    // Open the database and create tables if they don't exist
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  // Create database tables
  Future<void> _createTables(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        isExpense INTEGER NOT NULL
      )
    ''');
    debugPrint('Database tables created successfully');
  }

  // CRUD Operations for Transactions

  // Create - Insert a new transaction
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;

    final result = await db.insert('transactions', {
      'id': transaction.id,
      'title': transaction.title,
      'amount': transaction.amount,
      'date': transaction.date.toIso8601String(),
      'category': transaction.category,
      'isExpense': transaction.isExpense ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    debugPrint('Transaction inserted: ${transaction.title}');
    return result;
  }

  // Read - Get all transactions
  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC', // Newest first
    );

    return List.generate(maps.length, (i) {
      return Transaction(
        id: maps[i]['id'],
        title: maps[i]['title'],
        amount: maps[i]['amount'],
        date: DateTime.parse(maps[i]['date']),
        category: maps[i]['category'],
        isExpense: maps[i]['isExpense'] == 1,
      );
    });
  }

  // Read - Get transactions by category
  Future<List<Transaction>> getTransactionsByCategory(String category) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Transaction(
        id: maps[i]['id'],
        title: maps[i]['title'],
        amount: maps[i]['amount'],
        date: DateTime.parse(maps[i]['date']),
        category: maps[i]['category'],
        isExpense: maps[i]['isExpense'] == 1,
      );
    });
  }

  // Update - Modify an existing transaction
  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;

    final result = await db.update(
      'transactions',
      {
        'title': transaction.title,
        'amount': transaction.amount,
        'date': transaction.date.toIso8601String(),
        'category': transaction.category,
        'isExpense': transaction.isExpense ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [transaction.id],
    );

    debugPrint('Transaction updated: ${transaction.title}');
    return result;
  }

  // Delete - Remove a transaction
  Future<int> deleteTransaction(String id) async {
    final db = await database;

    final result = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    debugPrint('Transaction deleted: $id');
    return result;
  }

  // Delete all data (for testing or reset)
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('transactions');
    debugPrint('All data deleted');
  }

  // Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
