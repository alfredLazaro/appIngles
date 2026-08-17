import "package:flutter/widgets.dart";
import "package:sqflite/sqflite.dart";
import "DataBaseHelper.dart";
import "db_constants.dart";

class DailyActivityDao {
  final dbHelper = DatabaseService();

  Future<void> record(int userId, String date) async {
    try {
      final db = await dbHelper.database;
      await db.insert(
        DBTables.daily_activity,
        {DailyActivityFields.user_id: userId, DailyActivityFields.date: date},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ DailyActivityDao.record error: $e');
      rethrow;
    }
  }

  Future<Set<DateTime>> getPracticeDates(int userId) async {
    try {
      final db = await dbHelper.database;
      final rows = await db.rawQuery(
        'SELECT DISTINCT ${DailyActivityFields.date} FROM ${DBTables.daily_activity} '
        'WHERE ${DailyActivityFields.user_id} = ?',
        [userId],
      );
      return rows.map((r) {
        final parts = (r[DailyActivityFields.date] as String).split('-');
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }).toSet();
    } catch (e) {
      debugPrint('❌ DailyActivityDao.getPracticeDates error: $e');
      return {};
    }
  }
}
