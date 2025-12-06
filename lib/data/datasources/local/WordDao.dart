import "package:sqflite/sqflite.dart";
import "../../models/pf_ing_model.dart";
import "DataBaseHelper.dart";

class WordDao {
  final dbHelper = DatabaseService();

  Future<int> insertWord(PfIng pfIng) async {
    final db = await dbHelper.database;
    final id = await db.insert(
      'Word',
      pfIng.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<List<PfIng>> getAllPfIng() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Word');

    return List.generate(maps.length, (i) {
      return PfIng.fromMap(maps[i]);
    });
  }

  Future<List<PfIng>> getAllWordBasic() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Word',
      columns: [
        'id',
        'word',
        'sentence'
      ], // Solo estas columnas serán recuperadas
    );

    return List.generate(maps.length, (i) {
      return PfIng.fromPartialMap(maps[i]); // Usa un constructor adaptado
    });
  }

/*   Future<List<PfIng>> getLastPfIngBasic() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Word',
      columns: ['id', 'word', 'sentence'],
      orderBy: 'id DESC', // Ordena por los más recientes
      limit: 9, // Solo los últimos 9
    );

    return List.generate(maps.length, (i) {
      return PfIng.fromPartialMap(maps[i]);
    });
  } */

  Future<List<Map<String, dynamic>>> getLastPfIngBasic() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Word',
      columns: ['id', 'word', 'sentence'],
      orderBy: 'id DESC', // Ordena por los más recientes
      limit: 9, // Solo los últimos 9
    );

    return maps;
  }

  Future<void> updatePfIng(PfIng pfIng) async {
    final db = await dbHelper.database;
    pfIng.updatedAt = DateTime.now().toIso8601String();
    await db.update(
      'Word',
      pfIng.toMap(),
      where: 'id = ?',
      whereArgs: [pfIng.id],
    );
  }

  Future<void> updateSentence(int id, String sentence) async {
    final db = await dbHelper.database;
    await db.update(
      'Word',
      {
        'sentence': sentence,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePfIng(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'Word',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllWordsWithImages() async {
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
  }

  Future<int> countWords() async {
    final db = await dbHelper.database;
    final total = await db.rawQuery('''
      SELECT COUNT(*) FROM Word
      ''');
    int? count = Sqflite.firstIntValue(total);
    return count ?? 0;
  }

  Future<List<Map<String, dynamic>>> getWordsForPractice(int limit) async {
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
  }
}
