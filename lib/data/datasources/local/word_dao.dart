import "package:flutter/widgets.dart";
import "package:sqflite/sqflite.dart";
import "../../models/word_model.dart";
import "DataBaseHelper.dart";

class WordDao {
  final dbHelper = DatabaseService();
  Future<int> insertWord(WordModel word) async {
    try {
      final db = await dbHelper.database;
      final id = await db.insert(
        'Word',
        word.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      _logError('insertWord', e, {'word': word.word});
      rethrow; // Or return -1 if you prefer silent failure
    }
  }

  Future<void> updateWord(WordModel word) async {
    try {
      final db = await dbHelper.database;
      word.updatedAt = DateTime.now().toIso8601String();
      final rowsUpdated = await db.update(
        'Word',
        word.toMap(),
        where: 'id = ?',
        whereArgs: [word.id],
      );

      if (rowsUpdated == 0) {
        throw Exception('Word with id ${word.id} not found');
      }
    } catch (e) {
      _logError('updateWord', e, {'id': word.id});
      rethrow;
    }
  }

  Future<void> updateSentence(int id, String sentence) async {
    try {
      final db = await dbHelper.database;
      final rowsUpdated = await db.update(
        'Word',
        {
          'sentence': sentence,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsUpdated == 0) {
        throw Exception('Word with id $id not found for sentence update');
      }
    } catch (e) {
      _logError('updateSentence', e, {'id': id});
      rethrow;
    }
  }

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

  Future<void> deleteWord(int id) async {
    try {
      final db = await dbHelper.database;
      final rowsDeleted = await db.delete(
        'Word',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsDeleted == 0) {
        throw Exception('Word with id $id not found for deletion');
      }
    } catch (e) {
      _logError('deleteWord', e, {'id': id});
      rethrow;
    }
  }

  Future<int> countWords() async {
    try {
      final db = await dbHelper.database;
      final total = await db.rawQuery('SELECT COUNT(*) FROM Word');
      int? count = Sqflite.firstIntValue(total);
      return count ?? 0;
    } catch (e) {
      _logError('countWords', e);
      return 0; // Default to 0 on error
    }
  }

  Future<List<WordModel>> getAllWords() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('Word');

      return List.generate(maps.length, (i) {
        return WordModel.fromMap(maps[i]);
      });
    } catch (e) {
      _logError('getAllWords', e);
      return []; // Return empty list on error
    }
  }

  Future<List<Map<String, dynamic>>> getLastWordBasic() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Word',
        columns: ['id', 'word', 'sentence'],
        orderBy: 'id DESC',
        limit: 9,
      );

      return maps;
    } catch (e) {
      _logError('getLastWordBasic', e);
      return [];
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

  Future<List<Map<String, dynamic>>> getWordsForPractice(int limit) async {
    try {
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        w.id,
        w.word,
        w.definition,
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
          sentence
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

  // ============ HELPER METHOD FOR LOGGING ============
  void _logError(String methodName, dynamic error,
      [Map<String, dynamic>? context]) {
    debugPrint('❌ WordDao.$methodName error: $error');
    if (context != null) {
      debugPrint('   Context: $context');
    }
  }
}
