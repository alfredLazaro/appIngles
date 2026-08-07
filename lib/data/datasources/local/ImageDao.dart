import 'package:first_app/data/datasources/local/db_constants.dart';

import '../../models/image_model.dart';
import 'DataBaseHelper.dart';

class ImageDao {
  final dbHelper = DatabaseService();
  Future<int> insertImage(Image_Model imag) async {
    final db = await dbHelper.database;
    return await db.insert('Image', imag.toMap());
  }

  Future<List<Image_Model>> getAllImgs() async {
    final db = await dbHelper.database;
    final result = await db.query('Image');
    return result.map((json) => Image_Model.fromMap(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getLastImages({int limit = 9}) async {
    final db = await dbHelper.database;
    return await db.query(
      'Image',
      orderBy: 'id DESC',
      limit: limit,
    );
  }

  Future<int> updateImag(Image_Model img) async {
    final db = await dbHelper.database;
    return await db.update(
      'Image',
      img.toMap(),
      where: 'id = ?',
      whereArgs: [img.id],
    );
  }

  Future<int> deleteImag(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'Image',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Image_Model?> getImagById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'Image',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Image_Model.fromMap(result.first);
    }
    return null;
  }

  Future<List<Image_Model>> getByword_id(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'Image',
      where: 'word_id = ?',
      whereArgs: [id],
    );
    return result.map((e) => Image_Model.fromMap(e)).toList();
  }

  Future<int> deleteByword_id(int id) async {
    final db = await dbHelper.database;
    final result = await db.delete(
      'Image',
      where: 'word_id = ?',
      whereArgs: [id],
    );
    return result;
  }

  Future<Map<int, List<Image_Model>>> getImagesByword_ids(
      List<int> word_ids) async {
    if (word_ids.isEmpty) return {};

    final db = await dbHelper.database;

    // Convertir lista a string para rawQuery
    final idsString = word_ids.join(', ');

    // Consulta más eficiente con rawQuery
    final results = await db.rawQuery('''
    SELECT 
      ${ImageFields.id},
      ${ImageFields.word_id},
      ${ImageFields.name},
      ${ImageFields.url},
      ${ImageFields.tinyurl},
      ${ImageFields.author},
      ${ImageFields.source}
    FROM ${DBTables.image}
    WHERE ${ImageFields.word_id} IN ($idsString)
    ORDER BY ${ImageFields.word_id}, ${ImageFields.id}
  ''');

    return _groupImages(results);
  }

// Función helper para agrupar
  Map<int, List<Image_Model>> _groupImages(List<Map<String, dynamic>> rows) {
    final Map<int, List<Image_Model>> result = {};

    for (final row in rows) {
      final image = Image_Model.fromMap(row);
      final word_id = row[ImageFields.word_id] as int;

      result.putIfAbsent(word_id, () => []);
      result[word_id]!.add(image);
    }

    return result;
  }
}
