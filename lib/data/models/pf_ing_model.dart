class PfIng {
  final int? id;
  final String word;
  final String definition;
  final String sentence;
  int learn;
  String createdAt;
  String updatedAt;

  PfIng({
    this.id,
    required this.word,
    required this.definition,
    required this.sentence,
    required this.learn,
    required this.createdAt,
    required this.updatedAt,
  });

  PfIng copyWith({
    int? id,
    String? word,
    String? definition,
    String? sentence,
    int? learn,
    String? createdAt,
    String? updatedAt,
  }) {
    return PfIng(
      id: id ?? this.id,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      sentence: sentence ?? this.sentence,
      learn: learn ?? this.learn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  PfIng.partial({
    this.id,
    required this.word,
    required this.sentence,
  })  : definition = '',
        learn = 0,
        createdAt = '',
        updatedAt = '';

  factory PfIng.fromMap(Map<String, dynamic> map) {
    return PfIng(
      id: map['id'],
      definition: map['definition'],
      word: map['word'],
      sentence: map['sentence'],
      learn: map['learn'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
  factory PfIng.fromPartialMap(Map<String, dynamic> map) {
    return PfIng.partial(
      id: map['id'],
      word: map['word'],
      sentence: map['sentence'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'definition': definition,
      'word': word,
      'sentence': sentence,
      'learn': learn,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory PfIng.fromJson(Map<String, dynamic> json) {
    return PfIng(
      id: json['id'],
      definition: json['definition'],
      word: json['word'],
      sentence: json['sentence'],
      learn: json['learn'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
