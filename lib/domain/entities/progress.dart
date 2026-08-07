class Progress {
  final int? id;
  final int word_id;
  final String word;
  final int learn;
  final DateTime updatedAt;
  final int? userId;
  final DateTime? syncedAt;

  const Progress({
    this.id,
    required this.word_id,
    required this.word,
    required this.learn,
    required this.updatedAt,
    this.userId,
    this.syncedAt,
  });

  Progress copyWith({
    int? id,
    int? word_id,
    String? word,
    int? learn,
    DateTime? updatedAt,
    int? userId,
    DateTime? syncedAt,
  }) {
    return Progress(
      id: id ?? this.id,
      word_id: word_id ?? this.word_id,
      word: word ?? this.word,
      learn: learn ?? this.learn,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}