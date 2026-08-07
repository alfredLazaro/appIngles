import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/domain/entities/image_search_result.dart';
import 'package:first_app/domain/entities/word_image.dart';

abstract class ImageRepository {
  Future<List<ImageSearchResult>> searchImages(String query);
  Future<List<int>> saveImages(List<ImageSearchResult> images, int word_id);
  Future<List<WordImage>> getImagesByword_id(int word_id);

  Future<Map<int, List<FlashcardImage>>> getImagesByword_ids(List<int> word_ids);
}
