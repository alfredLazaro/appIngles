import "package:flutter/widgets.dart";
import "package:sqflite/sqflite.dart";
import "DataBaseHelper.dart";
import "db_constants.dart";
import "outbox_dao.dart";

class DailyActivityDao {
  final dbHelper = DatabaseService();
  final OutboxDao _outboxDao;

  DailyActivityDao({required OutboxDao outboxDao}) : _outboxDao = outboxDao;

  static const String _entityType = 'daily_activity';

  int dayNumber(String date) {
    final parts = date.split('-');
    final day = DateTime.utc(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    return day.difference(DateTime.utc(1970, 1, 1)).inDays;
  }

  Future<void> record(int userId, String date) async {
    try {
      final db = await dbHelper.database;
      final now = DateTime.now().toIso8601String();

      await db.transaction((txn) async {
        await txn.insert(
          DBTables.dailyActivity,
          {
            DailyActivityFields.user_id: userId,
            DailyActivityFields.date: date,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await _outboxDao.enqueueInTransaction(
          txn,
          _entityType,
          dayNumber(date),
          {DailyActivityFields.user_id: userId, DailyActivityFields.date: date},
          now,
        );
      });
    } catch (e) {
      debugPrint('❌ DailyActivityDao.record error: $e');
      rethrow;
    }
  }

  Future<void> mergeDates(int userId, Set<DateTime> dates) async {
    try {
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        for (final d in dates) {
          final date = '${d.year.toString().padLeft(4, '0')}-'
              '${d.month.toString().padLeft(2, '0')}-'
              '${d.day.toString().padLeft(2, '0')}';
          await txn.insert(
            DBTables.dailyActivity,
            {
              DailyActivityFields.user_id: userId,
              DailyActivityFields.date: date,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      debugPrint('❌ DailyActivityDao.mergeDates error: $e');
      rethrow;
    }
  }

  Future<Set<DateTime>> getPracticeDates(int userId) async {
    try {
      final db = await dbHelper.database;
      final rows = await db.rawQuery(
        'SELECT DISTINCT ${DailyActivityFields.date} FROM ${DBTables.dailyActivity} '
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