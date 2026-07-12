import "package:flutter/widgets.dart";
import "package:sqflite/sqflite.dart";
import "DataBaseHelper.dart";

class WordPracticeDao {
  final dbHelper = DatabaseService();

  Future<void> updateLearn(int id, int count) async {
    try {
      final db = await dbHelper.database;
      final rowsUpdated = await db.update(
        'Word',
        {
          'learn': count,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsUpdated == 0) {
        throw Exception('Word with id $id not found for learn update');
      }
    } catch (e) {
      _logError('updateLearn', e, {'id': id, 'count': count});
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getWordsForPractice(int limit) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        w.id,
        w.word,
        w.definition,
        w.phonetic,
        w.sentence,
        w.learn
      FROM Word w
      LEFT JOIN Image i ON w.id = i.wordId
      GROUP BY w.id
      ORDER BY w.learn ASC, w.id DESC
      LIMIT ?
    ''', [limit]);

      return result;
    } catch (e) {
      _logError('getWordsForPractice', e, {'limit': limit});
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSentencesForPractice(int limit) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT 
          id,
          sentence,
          learn
        FROM Word
        WHERE sentence IS NOT NULL AND sentence != ''
        ORDER BY learn ASC, id DESC
        LIMIT ?
      ''', [limit]);

      return result;
    } catch (e) {
      _logError('getSentencesForPractice', e, {'limit': limit});
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> gettWordDefForPractice(int limit) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Word',
        columns: ['id', 'word', 'definition'],
        orderBy: 'learn ASC, id DESC',
        limit: limit,
      );

      return maps;
    } catch (e) {
      _logError('gettWordDefForPractice', e);
      return [];
    }
  }

  Future<int> countSentences() async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM Word WHERE sentence IS NOT NULL AND sentence != ""');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      _logError('countSentences', e);
      return 0;
    }
  }

  void _logError(String methodName, dynamic error,
      [Map<String, dynamic>? context]) {
    debugPrint('❌ WordPracticeDao.$methodName error: $error');
    if (context != null) {
      debugPrint('   Context: $context');
    }
  }
}
