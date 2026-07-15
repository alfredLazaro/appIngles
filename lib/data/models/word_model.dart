class WordModel {
  final int? id;
  final String word;
  final String partOfSpeech; // Added partOfSpeech field to represent the part of speech of the word
  final String phonetic;
  final String definition;
  final String sentence;
  int learn;
  String createdAt;
  String updatedAt;

  WordModel({
    this.id,
    required this.word,
    required this.partOfSpeech,
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
    String? partOfSpeech,
  }) {
    return WordModel(
      id: id ?? this.id,
      word: word ?? this.word,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
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
    required this.partOfSpeech,
    required this.sentence,
  })  : definition = '',
        phonetic = '', //need correction
        learn = 0,
        createdAt = '',
        updatedAt = '';

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'],
      word: map['word'] ?? '',
      partOfSpeech: map['partOfSpeech'] ?? '',
      phonetic: map['phonetic'] ?? '',
      definition: map['definition'] ?? '',
      sentence: map['sentence'] ?? '',
      learn: map['learn'] ?? 0,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }
  factory WordModel.fromPartialMap(Map<String, dynamic> map) {
    return WordModel.partial(
      id: map['id'],
      word: map['word'],
      partOfSpeech: map['partOfSpeech'] ?? '',
      sentence: map['sentence'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'definition': definition,
      'word': word,
      'partOfSpeech': partOfSpeech,
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
      word: json['word'] ?? '',
      partOfSpeech: json['partOfSpeech'] ?? '',
      phonetic: json['phonetic'] ?? '',
      definition: json['definition'] ?? '',
      sentence: json['sentence'] ?? '',
      learn: json['learn'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
