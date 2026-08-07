class TranslationEntity {
  final int? id;
  final int word_id;
  final String wordTranslate;
  final List<String> alternatives;
  final DateTime? createdAt;

  const TranslationEntity({
    this.id,
    required this.word_id,
    required this.wordTranslate,
    this.alternatives = const [],
    this.createdAt,
  });

  TranslationEntity copyWith({
    int? id,
    int? word_id,
    String? wordTranslate,
    List<String>? alternatives,
    DateTime? createdAt,
  }) {
    return TranslationEntity(
      id: id ?? this.id,
      word_id: word_id ?? this.word_id,
      wordTranslate: wordTranslate ?? this.wordTranslate,
      alternatives: alternatives ?? this.alternatives,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TranslationEntity(id: $id, word_id: $word_id, wordTranslate: $wordTranslate, alternatives: $alternatives)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TranslationEntity &&
        other.id == id &&
        other.word_id == word_id &&
        other.wordTranslate == wordTranslate &&
        _listEquals(other.alternatives, alternatives);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        word_id.hashCode ^
        wordTranslate.hashCode ^
        alternatives.hashCode;
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
