// domain/entities/translation.dart

/// @deprecated Use [TranslationEntity] instead.
/// Kept temporarily for data layer compatibility.
class Translation {
  final int? id;
  final String wordTranslate;
  final int word_id;
  final String? alternatives;

  Translation({
    this.id,
    required this.wordTranslate,
    required this.word_id,
    this.alternatives,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word_translate': wordTranslate,
      'word_id': word_id,
      'alternatives': alternatives,
    };
  }

  factory Translation.fromMap(Map<String, dynamic> map) {
    return Translation(
      id: map['id'] as int?,
      wordTranslate: map['word_translate'] as String? ?? '',
      word_id: (map['word_id'] as num?)?.toInt() ?? 0,
      alternatives: map['alternatives'] as String?,
    );
  }

  Translation copyWith({
    int? id,
    String? wordTranslate,
    int? word_id,
    String? alternatives,
  }) {
    return Translation(
      id: id ?? this.id,
      wordTranslate: wordTranslate ?? this.wordTranslate,
      word_id: word_id ?? this.word_id,
      alternatives: alternatives ?? this.alternatives,
    );
  }

  @override
  String toString() {
    return 'Translation(id: $id, wordTranslate: $wordTranslate, word_id: $word_id, alternatives: $alternatives)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Translation &&
        other.id == id &&
        other.wordTranslate == wordTranslate &&
        other.word_id == word_id &&
        other.alternatives == alternatives;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        wordTranslate.hashCode ^
        word_id.hashCode ^
        alternatives.hashCode;
  }
}