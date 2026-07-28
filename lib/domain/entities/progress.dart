class Progress {
  final int? id;
  final int wordId;
  final String word;
  final int learn;
  final DateTime updatedAt;
  final int? userId;
  final DateTime? syncedAt;

  const Progress({
    this.id,
    required this.wordId,
    required this.word,
    required this.learn,
    required this.updatedAt,
    this.userId,
    this.syncedAt,
  });

  Progress copyWith({
    int? id,
    int? wordId,
    String? word,
    int? learn,
    DateTime? updatedAt,
    int? userId,
    DateTime? syncedAt,
  }) {
    return Progress(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      learn: learn ?? this.learn,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}