import 'package:first_app/domain/entities/word_image.dart';

abstract class ImageRepository {
  Future<List<Map<String, dynamic>>> searchImages(String query);
  Future<List<int>> saveImages(List<Map<String, dynamic>> images, int wordId);
  Future<List<WordImage>> getImagesByWordId(int wordId);
}
