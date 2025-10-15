import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as model;

class DatabaseService {
  static Database? _database;
  
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'investify.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        roundUpAmount REAL NOT NULL,
        category TEXT NOT NULL,
        date INTEGER NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  static Future<int> insertTransaction(model.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  static Future<List<model.Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return maps.map((map) => model.Transaction.fromMap(map)).toList();
  }

  static Future<double> getTotalInvestment() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(roundUpAmount) as total FROM transactions');
    return result.first['total'] as double? ?? 0.0;
  }

  static Future<double> getTotalExpenditure() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM transactions');
    return result.first['total'] as double? ?? 0.0;
  }

  static Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteAllTransactions() async {
    final db = await database;
    return await db.delete('transactions');
  }
}