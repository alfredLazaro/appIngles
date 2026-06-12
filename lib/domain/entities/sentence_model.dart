class SentenceModel {
  final int id;
  final String sentence;

  const SentenceModel({
    required this.id,
    required this.sentence,
  });

  factory SentenceModel.fromMap(Map<String, dynamic> map) {
    return SentenceModel(
      id: map['id'] as int,
      sentence: map['sentence'] as String,
    );
  }
}
