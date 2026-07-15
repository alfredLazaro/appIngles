import "package:flutter/widgets.dart";
import "package:sqflite/sqflite.dart";
import "package:first_app/domain/entities/word_filter.dart";
import "DataBaseHelper.dart";

class WordBatchDao {
  final dbHelper = DatabaseService();

  Future<List<Map<String, dynamic>>> insertLotWords(
      List<Map<String, String>> words) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> results = [];

      final batch = db.batch();

      for (Map<String, String> word in words) {
        batch.insert(
          'Word',
          word,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      final ids = await batch.commit();

      for (int i = 0; i < words.length; i++) {
        results.add({
          'id': ids[i],
          'word': words[i]['word'],
        });
      }

      return results;
    } catch (e) {
      _logError('insertLotWords', e, {'wordsCount': words.length});
      rethrow;
    }
  }

  Future<void> batchUpdateLearnCounts(Map<int, int> updates) async {
    try {
      final db = await dbHelper.database;
      final batch = db.batch();
      final now = DateTime.now().toIso8601String();

      updates.forEach((id, count) {
        batch.update(
          'Word',
          {
            'learn': count,
            'updated_at': now,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      });

      await batch.commit(noResult: true);
    } catch (e) {
      _logError('batchUpdateLearnCounts', e,
          {'updatesCount': updates.length});
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllWordsWithImages() async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT 
          w.id,
          w.word,
          w.definition,
          MIN(i.tinyurl) as tinyImageUrl
        FROM Word w
        LEFT JOIN Image i ON w.id = i.wordId
        GROUP BY w.id
        ORDER BY w.id DESC
      ''');

      return result;
    } catch (e) {
      _logError('getAllWordsWithImages', e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getWordsWithImagesPaginated({
    required int page,
    required int pageSize,
    String? searchQuery,
    WordFilterMode? filterMode,
  }) async {
    try {
      final db = await dbHelper.database;
      final offset = (page - 1) * pageSize;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        whereClause = 'WHERE w.word LIKE ? OR w.definition LIKE ?';
        whereArgs = ['%$searchQuery%', '%$searchQuery%'];
      }

      String havingClause = '';
      if (filterMode != null && filterMode != WordFilterMode.all) {
        switch (filterMode) {
          case WordFilterMode.noTranslation:
            havingClause = 'HAVING translationCount = 0';
          case WordFilterMode.noSentence:
            havingClause =
                "HAVING (sentenceValue IS NULL OR sentenceValue = '')";
          case WordFilterMode.incomplete:
            havingClause =
                "HAVING (translationCount = 0 OR sentenceValue IS NULL OR sentenceValue = '')";
          case WordFilterMode.all:
            break;
        }
      }

      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        w.id,
        w.word,
        w.definition,
        MIN(i.tinyurl) as tinyImageUrl,
        w.learn,
        w.sentence,
        w.created_at,
        w.updated_at,
        COUNT(t.id) as translationCount,
        MAX(w.sentence) as sentenceValue
      FROM Word w
      LEFT JOIN Image i ON w.id = i.wordId
      LEFT JOIN Translation t ON w.id = t.wordId
      $whereClause
      GROUP BY w.id
      $havingClause
      ORDER BY w.id DESC
      LIMIT ? OFFSET ?
    ''', [...whereArgs, pageSize, offset]);

      return result;
    } catch (e) {
      _logError('getWordsWithImagesPaginated', e,
          {'page': page, 'pageSize': pageSize, 'searchQuery': searchQuery});
      return [];
    }
  }

  Future<List<int>> getAllLearnCounts() async {
    try {
      final db = await dbHelper.database;
      final rows = await db.rawQuery('SELECT learn FROM Word');
      return rows.map((r) => (r['learn'] as int?) ?? 0).toList();
    } catch (e) {
      _logError('getAllLearnCounts', e);
      return [];
    }
  }

  void _logError(String methodName, dynamic error,
      [Map<String, dynamic>? context]) {
    debugPrint('❌ WordBatchDao.$methodName error: $error');
    if (context != null) {
      debugPrint('   Context: $context');
    }
  }
}
