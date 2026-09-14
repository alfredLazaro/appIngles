import "package:flutter/widgets.dart";
import "package:sqflite/sqflite.dart";
import "package:first_app/data/datasources/local/DataBaseHelper.dart";

class AppPreferencesDao {
  final dbHelper = DatabaseService();

  Future<String?> getString(String key) async {
    try {
      final db = await dbHelper.database;
      final rows = await db.query(
        'app_preferences',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: [key],
      );
      if (rows.isEmpty) return null;
      return rows.first['value'] as String?;
    } catch (e) {
      debugPrint('❌ AppPreferencesDao.getString error: $e');
      return null;
    }
  }

  Future<void> setString(String key, String value) async {
    try {
      final db = await dbHelper.database;
      await db.insert(
        'app_preferences',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ AppPreferencesDao.setString error: $e');
      rethrow;
    }
  }
}
