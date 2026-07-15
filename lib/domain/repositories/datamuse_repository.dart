import 'package:first_app/domain/entities/related_word.dart';

abstract class DatamuseRepository {
  Future<List<RelatedWord>> getMeansLike(String word);
}
