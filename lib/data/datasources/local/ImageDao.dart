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

  Future<List<Image_Model>> getByWordId(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'Image',
      where: 'wordId = ?',
      whereArgs: [id],
    );
    return result.map((e) => Image_Model.fromMap(e)).toList();
  }

  Future<int> deleteByWordId(int id) async {
    final db = await dbHelper.database;
    final result = await db.delete(
      'Image',
      where: 'wordId = ?',
      whereArgs: [id],
    );
    return result;
  }
}
