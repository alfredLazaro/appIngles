import 'package:first_app/data/models/image_model.dart';
import 'package:first_app/domain/entities/word_image.dart';

abstract class ImageRepository {
  Future<List<Map<String, dynamic>>> searchImages(String query);
  Future<List<int>> saveImages(List<Map<String, dynamic>> images, int wordId);
  Future<List<WordImage>> getImagesByWordId(int wordId);

  Future<Map<int, List<Image_Model>>> getImagesByWordIds(List<int> wordIds);
}
