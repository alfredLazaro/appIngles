import 'package:first_app/domain/entities/progress.dart';

class ProgressModel {
  final int? id;
  final int wordId;
  final String word;
  int learn;
  String updatedAt;
  int? userId;
  String? syncedAt;

  ProgressModel({
    this.id,
    required this.wordId,
    required this.word,
    required this.learn,
    required this.updatedAt,
    this.userId,
    this.syncedAt,
  });

  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel(
      id: map['id'] as int?,
      wordId: map['word_id'] as int,
      word: map['word'] as String? ?? '',
      learn: map['learn'] as int? ?? 0,
      updatedAt: map['updated_at'] as String? ?? '',
      userId: map['user_id'] as int?,
      syncedAt: map['synced_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'word_id': wordId,
      'word': word,
      'learn': learn,
      'updated_at': updatedAt,
      if (userId != null) 'user_id': userId,
      if (syncedAt != null) 'synced_at': syncedAt,
    };
  }

  Progress toEntity() {
    return Progress(
      id: id,
      wordId: wordId,
      word: word,
      learn: learn,
      updatedAt: DateTime.parse(updatedAt),
      userId: userId,
      syncedAt: syncedAt != null ? DateTime.parse(syncedAt!) : null,
    );
  }

  static ProgressModel fromEntity(Progress entity) {
    return ProgressModel(
      id: entity.id,
      wordId: entity.wordId,
      word: entity.word,
      learn: entity.learn,
      updatedAt: entity.updatedAt.toIso8601String(),
      userId: entity.userId,
      syncedAt: entity.syncedAt?.toIso8601String(),
    );
  }
}