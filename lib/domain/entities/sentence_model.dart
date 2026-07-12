import 'package:equatable/equatable.dart';

class SentenceModel extends Equatable {
  final int id;
  final String sentence;
  final int learnCount;

  const SentenceModel({
    required this.id,
    required this.sentence,
    this.learnCount = 0,
  });

  factory SentenceModel.fromMap(Map<String, dynamic> map) {
    return SentenceModel(
      id: map['id'] as int,
      sentence: map['sentence'] as String,
      learnCount: map['learn'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, sentence, learnCount];
}
