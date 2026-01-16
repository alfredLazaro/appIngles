class WordModel {
  final int? id;
  final String word;
  final String phonetic;
  final String definition;
  final String sentence;
  int learn;
  String createdAt;
  String updatedAt;

  WordModel({
    this.id,
    required this.word,
    required this.phonetic,
    required this.definition,
    required this.sentence,
    required this.learn,
    required this.createdAt,
    required this.updatedAt,
  });

  WordModel copyWith({
    int? id,
    String? word,
    String? phonetic,
    String? definition,
    String? sentence,
    int? learn,
    String? createdAt,
    String? updatedAt,
  }) {
    return WordModel(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      definition: definition ?? this.definition,
      sentence: sentence ?? this.sentence,
      learn: learn ?? this.learn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  WordModel.partial({
    this.id,
    required this.word,
    required this.sentence,
  })  : definition = '',
        phonetic = '', //need correction
        learn = 0,
        createdAt = '',
        updatedAt = '';

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'],
      word: map['word'],
      phonetic: map['phonetic'],
      definition: map['definition'],
      sentence: map['sentence'],
      learn: map['learn'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
  factory WordModel.fromPartialMap(Map<String, dynamic> map) {
    return WordModel.partial(
      id: map['id'],
      word: map['word'],
      sentence: map['sentence'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'definition': definition,
      'word': word,
      'phonetic': phonetic,
      'sentence': sentence,
      'learn': learn,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'],
      word: json['word'],
      phonetic: json['phonetic'],
      definition: json['definition'],
      sentence: json['sentence'],
      learn: json['learn'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
