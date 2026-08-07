import 'package:first_app/data/models/image_model.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/domain/entities/word_image.dart';

class ImageMapper {
  static FlashcardImage toFlashcardImage(Image_Model imgModel) {
    return FlashcardImage(
        url: imgModel.url ?? '',
        author: imgModel.author,
        source: imgModel.source);
  }

  static WordImage toWordImage(Image_Model imgModel) {
    return WordImage(
      id: imgModel.id,
      word_id: imgModel.word_id ?? 0,
      url: imgModel.url ?? '',
      tinyUrl: imgModel.tinyurl ?? '',
      name: imgModel.name ?? '',
      author: imgModel.author ?? '',
      source: imgModel.source ?? '',
    );
  }

  List<FlashcardImage> mapImageModelsToFlashcardImages(
      List<Image_Model> imageModels) {
    return imageModels
        .where((image) => image.url != null && image.url!.isNotEmpty)
        .map((image) => FlashcardImage(
              url: image.url ?? '',
              author: image.author,
              source: image.source,
            ))
        .toList();
  }

  static Map<int, List<FlashcardImage>> mapToFlashcardImages(
    Map<int, List<Image_Model>> imagesMap,
  ) {
    return imagesMap.map((word_id, imageModels) {
      final flashcardImages = imageModels
          .map((image) => toFlashcardImage(image))
          .whereType<FlashcardImage>()
          .toList();
      return MapEntry(word_id, flashcardImages);
    });
  }
}
