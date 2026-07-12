// domain/entities/translation.dart

/// @deprecated Use [TranslationEntity] instead.
/// Kept temporarily for data layer compatibility.
class Translation {
  final int? id;
  final String wordTranslate;
  final int wordId;
  final String? alternatives;

  Translation({
    this.id,
    required this.wordTranslate,
    required this.wordId,
    this.alternatives,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wordTranslate': wordTranslate,
      'wordId': wordId,
      'alternatives': alternatives,
    };
  }

  factory Translation.fromMap(Map<String, dynamic> map) {
    return Translation(
      id: map['id'] as int?,
      wordTranslate: map['wordTranslate'] as String,
      wordId: map['wordId'] as int,
      alternatives: map['alternatives'] as String?,
    );
  }

  Translation copyWith({
    int? id,
    String? wordTranslate,
    int? wordId,
    String? alternatives,
  }) {
    return Translation(
      id: id ?? this.id,
      wordTranslate: wordTranslate ?? this.wordTranslate,
      wordId: wordId ?? this.wordId,
      alternatives: alternatives ?? this.alternatives,
    );
  }

  @override
  String toString() {
    return 'Translation(id: $id, wordTranslate: $wordTranslate, wordId: $wordId, alternatives: $alternatives)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Translation &&
        other.id == id &&
        other.wordTranslate == wordTranslate &&
        other.wordId == wordId &&
        other.alternatives == alternatives;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        wordTranslate.hashCode ^
        wordId.hashCode ^
        alternatives.hashCode;
  }
}