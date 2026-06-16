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

  Future<List<Map<String, dynamic>>> insertLotWords(
      List<Map<String, String>> words) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> results = [];

      // Use batch for better performance
      final batch = db.batch();

      for (Map<String, String> word in words) {
        batch.insert(
          'Word',
          word, // Use the existing toMap() method from WordModel
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // Execute batch and get the inserted IDs
      final ids = await batch.commit();

      // Map the results with only ID and word string
      for (int i = 0; i < words.length; i++) {
        results.add({
          'id': ids[i],
          'word': words[i]['word'], // Only return the word string
        });
      }

      return results;
    } catch (e) {
      _logError('insertLotWords', e, {'wordsCount': words.length});
      rethrow;
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

  Future<List<Map<String, dynamic>>> getLastWordBasic({int limit = 9}) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Word',
        columns: ['id', 'word', 'sentence'],
        orderBy: 'id DESC',
        limit: limit,
      );

      return maps;
    } catch (e) {
      _logError('getLastWordBasic', e);
      return [];
    }
  }

  Future<List<WordModel>> getLastWords({int limit = 9}) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Word',
        orderBy: 'id DESC',
        limit: limit,
      );
      return maps.map((map) => WordModel.fromMap(map)).toList();
    } catch (e) {
      _logError('getLastWords', e);
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

  // ============ HELPER METHOD FOR LOGGING ============
  void _logError(String methodName, dynamic error,
      [Map<String, dynamic>? context]) {
    debugPrint('❌ WordDao.$methodName error: $error');
    if (context != null) {
      debugPrint('   Context: $context');
    }
  }

  Future<WordModel?> getWordById(int id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Word',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return WordModel.fromMap(maps.first);
    } catch (e) {
      _logError('getWordById', e, {'id': id});
      return null;
    }
  }

  Future<bool> wordExists(String word) async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM Word WHERE word=?',
        [word.trim()],
      );

      final count = Sqflite.firstIntValue(result) ?? 0;
      return count > 0;
    } catch (e) {
      _logError('wordExists', e, {'word': word});
      return false;
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
      _logError('batchUpdateLearnCounts', e, {'updatesCount': updates.length});
      rethrow;
    }
  }

  Future<List<WordModel>> searchWords(String query) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Word',
        where: 'word LIKE ? OR definition LIKE ? OR sentence LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
      );

      return maps.map((map) => WordModel.fromMap(map)).toList();
    } catch (e) {
      _logError('searchWords', e, {'query': query});
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getWordsWithImagesPaginated({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    try {
      final db = await dbHelper.database;
      final offset = (page - 1) * pageSize;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      // Add search filter if provided
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        whereClause = 'WHERE w.word LIKE ? OR w.definition LIKE ?';
        whereArgs = ['%$searchQuery%', '%$searchQuery%'];
      }

      // Build the query with pagination
      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        w.id,
        w.word,
        w.definition,
        MIN(i.tinyurl) as tinyImageUrl,
        w.learn,
        w.sentence,
        w.created_at,
        w.updated_at
      FROM Word w
      LEFT JOIN Image i ON w.id = i.wordId
      $whereClause
      GROUP BY w.id
      ORDER BY w.id DESC
      LIMIT ? OFFSET ?
    ''', [...whereArgs, pageSize, offset]);

      return result;
    } catch (e) {
      _logError('getAllWordsWithImagesPaginated', e,
          {'page': page, 'pageSize': pageSize, 'searchQuery': searchQuery});
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
  // Add this method to your WordDao class in lib/data/datasources/local/word_dao.dart

  /// Get all learn counts from the database (raw data)
  Future<List<int>> getAllLearnCounts() async {
    final db = await dbHelper.database;
    final rows = await db.rawQuery('SELECT learn FROM Word');
    return rows.map((r) => (r['learn'] as int?) ?? 0).toList();
  }
}
