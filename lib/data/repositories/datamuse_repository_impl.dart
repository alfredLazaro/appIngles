import 'package:first_app/domain/entities/related_word.dart';
import 'package:first_app/domain/repositories/datamuse_repository.dart';
import 'package:first_app/data/datasources/remote/datamuse_service.dart';

class DatamuseRepositoryImpl implements DatamuseRepository {
  final DatamuseService _datamuseService;

  DatamuseRepositoryImpl({
    required DatamuseService datamuseService,
  }) : _datamuseService = datamuseService;

  @override
  Future<List<RelatedWord>> getMeansLike(String word) async {
    try {
      return await _datamuseService.getMeansLike(word);
    } catch (e) {
      throw Exception('Error al buscar palabras similares: $e');
    }
  }
}
