import 'package:first_app/data/models/pf_ing_model.dart';
import 'package:first_app/data/models/image_model.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';

/// Convierte modelos de datos a entidades de dominio
class FlashcardMapper {
  static FlashcardWord toEntity(PfIng model) {
    return FlashcardWord(
      word: model.word,
      definition: model.definition,
      sentence: model.sentence,
      learnCount: 0, // O tomar de tu modelo si existe
    );
  }

  static FlashcardImage imageToEntity(Image_Model model) {
    return FlashcardImage(
      url: model.url ?? '',
      author: model.author,
      source: null, // Agregar si existe en tu modelo
    );
  }

  static List<FlashcardImage> imagesToEntities(List<Image_Model> models) {
    return models.map((m) => imageToEntity(m)).toList();
  }
}
