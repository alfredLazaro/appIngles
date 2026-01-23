import 'package:first_app/data/datasources/local/db_constants.dart';
import 'package:first_app/data/datasources/local/database_service.dart';
import 'package:sqflite/sqflite.dart';

class TranslationDao {
  final DatabaseService _databaseService = DatabaseService();

  // Insert a new translation
  Future<int> insertTranslation(Map<String, dynamic> translation) async {
    final db = await _databaseService.database;
    return await db.insert(
      DBTables.translation,
      translation,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert multiple translations for a word
  Future<List<int>> insertTranslations(
    int wordId,
    List<Map<String, dynamic>> translations,
  ) async {
    final db = await _databaseService.database;
    final List<int> ids = [];

    await db.transaction((txn) async {
      for (final translation in translations) {
        final data = {
          TranslationFields.wordId: wordId,
          TranslationFields.wordTranslate: translation['wordTranslate'],
          TranslationFields.alternatives: translation['alternatives'],
        };
        final id = await txn.insert(
          DBTables.translation,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        ids.add(id);
      }
    });

    return ids;
  }

  // Get all translations for a specific word
  Future<List<Map<String, dynamic>>> getTranslationsByWordId(
    int wordId,
  ) async {
    final db = await _databaseService.database;
    return await db.query(
      DBTables.translation,
      where: '${TranslationFields.wordId} = ?',
      whereArgs: [wordId],
    );
  }

  // Get a single translation by ID
  Future<Map<String, dynamic>?> getTranslationById(int id) async {
    final db = await _databaseService.database;
    final results = await db.query(
      DBTables.translation,
      where: '${TranslationFields.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Update a translation
  Future<int> updateTranslation(
    int id,
    Map<String, dynamic> translation,
  ) async {
    final db = await _databaseService.database;
    return await db.update(
      DBTables.translation,
      translation,
      where: '${TranslationFields.id} = ?',
      whereArgs: [id],
    );
  }

  // Delete a translation by ID
  Future<int> deleteTranslation(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      DBTables.translation,
      where: '${TranslationFields.id} = ?',
      whereArgs: [id],
    );
  }

  // Delete all translations for a specific word
  Future<int> deleteTranslationsByWordId(int wordId) async {
    final db = await _databaseService.database;
    return await db.delete(
      DBTables.translation,
      where: '${TranslationFields.wordId} = ?',
      whereArgs: [wordId],
    );
  }

  // Get all translations (for debugging or admin purposes)
  Future<List<Map<String, dynamic>>> getAllTranslations() async {
    final db = await _databaseService.database;
    return await db.query(DBTables.translation);
  }

  // Get translations with word details (JOIN query)
  Future<List<Map<String, dynamic>>> getTranslationsWithWordDetails(
    int wordId,
  ) async {
    final db = await _databaseService.database;
    return await db.rawQuery('''
      SELECT 
        t.${TranslationFields.id},
        t.${TranslationFields.wordTranslate},
        t.${TranslationFields.alternatives},
        w.${WordFields.word},
        w.${WordFields.definition}
      FROM ${DBTables.translation} t
      INNER JOIN ${DBTables.word} w 
        ON t.${TranslationFields.wordId} = w.${WordFields.id}
      WHERE t.${TranslationFields.wordId} = ?
    ''', [wordId]);
  }

  // Search translations by text (useful for finding words by translation)
  Future<List<Map<String, dynamic>>> searchTranslations(
    String searchTerm,
  ) async {
    final db = await _databaseService.database;
    return await db.query(
      DBTables.translation,
      where: '${TranslationFields.wordTranslate} LIKE ? OR ${TranslationFields.alternatives} LIKE ?',
      whereArgs: ['%$searchTerm%', '%$searchTerm%'],
    );
  }

  // Count translations for a word
  Future<int> getTranslationCount(int wordId) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM ${DBTables.translation}
      WHERE ${TranslationFields.wordId} = ?
    ''', [wordId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Batch insert translations (more efficient for multiple words)
  Future<void> batchInsertTranslations(
    List<Map<String, dynamic>> translations,
  ) async {
    final db = await _databaseService.database;
    final batch = db.batch();

    for (final translation in translations) {
      batch.insert(
        DBTables.translation,
        translation,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Update or insert translation (upsert pattern)
  Future<int> upsertTranslation(Map<String, dynamic> translation) async {
    final db = await _databaseService.database;
    
    if (translation.containsKey(TranslationFields.id)) {
      final id = translation[TranslationFields.id];
      final exists = await getTranslationById(id);
      
      if (exists != null) {
        await updateTranslation(id, translation);
        return id;
      }
    }
    
    return await insertTranslation(translation);
  }
}