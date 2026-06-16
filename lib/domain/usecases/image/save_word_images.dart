import 'package:first_app/domain/entities/image_search_result.dart';
import 'package:first_app/domain/repositories/image_repository.dart';

class SaveWordImagesUseCase {
  final ImageRepository _repository;

  SaveWordImagesUseCase(this._repository);

  Future<List<int>> call(
    List<ImageSearchResult> images,
    int wordId,
  ) async {
    if (wordId <= 0) {
      throw Exception('ID de palabra inválido');
    }

    if (images.isEmpty) {
      return [];
    }

    return await _repository.saveImages(images, wordId);
  }
}
