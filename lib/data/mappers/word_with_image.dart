import 'package:first_app/domain/entities/word_with_image.dart';

class WordWithImageMapper {
  static WordWithImage fromMap(Map<String, dynamic> map) {
    return WordWithImage(
      id: map['id'],
      word: map['word'] ?? '',
      definition: map['definition'] ?? '',
      tinyImageUrl: map['tinyImageUrl'], // Puede ser null
    );
  }

  static List<WordWithImage> fromMapList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => fromMap(map)).toList();
  }
}
