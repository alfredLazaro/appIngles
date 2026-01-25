// domain/entities/translation_entity.dart
import 'package:first_app/data/datasources/local/db_constants.dart';
import 'package:flutter/foundation.dart';

class TranslationEntity {
  final int? id;
  final int wordId;
  final String wordTranslate;
  final List<String> alternatives;
  final DateTime? createdAt;

  TranslationEntity({
    this.id,
    required this.wordId,
    required this.wordTranslate,
    this.alternatives = const [],
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) TranslationFields.id: id,
      TranslationFields.wordId: wordId,
      TranslationFields.wordTranslate: wordTranslate,
      TranslationFields.alternatives: alternatives.join('|'),
    };
  }

  factory TranslationEntity.fromMap(Map<String, dynamic> map) {
    return TranslationEntity(
      id: map[TranslationFields.id] as int?,
      wordId: map[TranslationFields.wordId] as int,
      wordTranslate: map[TranslationFields.wordTranslate] as String,
      alternatives: (map[TranslationFields.alternatives] as String? ?? '')
          .split('|')
          .where((item) => item.isNotEmpty)
          .toList(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

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
