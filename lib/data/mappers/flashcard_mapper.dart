import 'package:first_app/data/models/pf_ing_model.dart';
import 'package:first_app/data/models/image_model.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';

/// Convierte modelos de datos a entidades de dominio
class FlashcardMapper {
  static FlashcardWord toEntity(PfIng model) {
    return FlashcardWord(
      id: model.id!,
      word: model.word,
      definition: model.definition,
      sentence: model.sentence,
      learnCount: model.learn,
    );
  }

  static FlashcardImage imageToEntity(Image_Model model) {
    return FlashcardImage(
      url: model.url ?? '',
      author: model.author,
      source: model.source,
    );
  }

  static List<FlashcardImage> imagesToEntities(List<Image_Model> models) {
    return models.map((m) => imageToEntity(m)).toList();
  }
}
