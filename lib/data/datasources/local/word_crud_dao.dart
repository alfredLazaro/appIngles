import "package:flutter/widgets.dart";
import "package:sqflite/sqflite.dart";
import "../../models/word_model.dart";
import "DataBaseHelper.dart";

class WordCrudDao {
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

  Future<List<WordModel>> getAllWords() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('Word');

      return List.generate(maps.length, (i) {
        return WordModel.fromMap(maps[i]);
      });
    } catch (e) {
      _logError('getAllWords', e);
      return [];
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

  Future<int> countWords() async {
    try {
      final db = await dbHelper.database;
      final total = await db.rawQuery('SELECT COUNT(*) FROM Word');
      int? count = Sqflite.firstIntValue(total);
      return count ?? 0;
    } catch (e) {
      _logError('countWords', e);
      return 0;
    }
  }

  void _logError(String methodName, dynamic error,
      [Map<String, dynamic>? context]) {
    debugPrint('❌ WordCrudDao.$methodName error: $error');
    if (context != null) {
      debugPrint('   Context: $context');
    }
  }
}
