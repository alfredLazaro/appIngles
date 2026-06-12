// domain/entities/translation_entity.dart
import 'package:flutter/foundation.dart';

class TranslationEntity {
  final int? id;
  final int wordId;
  final String wordTranslate;
  final List<String> alternatives;
  final DateTime? createdAt;

  const TranslationEntity({
    this.id,
    required this.wordId,
    required this.wordTranslate,
    this.alternatives = const [],
    this.createdAt,
  });

  TranslationEntity copyWith({
    int? id,
    int? wordId,
    String? wordTranslate,
    List<String>? alternatives,
    DateTime? createdAt,
  }) {
    return TranslationEntity(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      wordTranslate: wordTranslate ?? this.wordTranslate,
      alternatives: alternatives ?? this.alternatives,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TranslationEntity(id: $id, wordId: $wordId, wordTranslate: $wordTranslate, alternatives: $alternatives)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TranslationEntity &&
        other.id == id &&
        other.wordId == wordId &&
        other.wordTranslate == wordTranslate &&
        listEquals(other.alternatives, alternatives);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        wordId.hashCode ^
        wordTranslate.hashCode ^
        alternatives.hashCode;
  }
}
