import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'DataBaseHelper.dart';

class UserDao {
  final dbHelper = DatabaseService();

  Future<Map<String, dynamic>?> getSession() async {
    try {
      final db = await dbHelper.database;
      final rows = await db.query('users', limit: 1);
      if (rows.isEmpty) return null;
      return rows.first;
    } catch (e) {
      debugPrint('❌ UserDao.getSession error: $e');
      return null;
    }
  }

  Future<void> saveSession(Map<String, dynamic> data) async {
    try {
      final db = await dbHelper.database;
      await db.insert(
        'users',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ UserDao.saveSession error: $e');
      rethrow;
    }
  }

  Future<void> clearSession() async {
    try {
      final db = await dbHelper.database;
      await db.delete('users');
    } catch (e) {
      debugPrint('❌ UserDao.clearSession error: $e');
      rethrow;
    }
  }

  Future<bool> hasSession() async {
    final db = await dbHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users'),
    );
    return (count ?? 0) > 0;
  }

  Future<int?> getUserId() async {
    final session = await getSession();
    return session?['id'] as int?;
  }
}