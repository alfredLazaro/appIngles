import 'package:first_app/domain/entities/image_search_result.dart';
import 'package:first_app/domain/repositories/image_repository.dart';

class SearchImagesUseCase {
  final ImageRepository _repository;

  SearchImagesUseCase(this._repository);

  Future<List<ImageSearchResult>> call(String query) async {
    if (query.trim().isEmpty) {
      throw Exception('La consulta no puede estar vacía');
    }
    return await _repository.searchImages(query);
  }
}
