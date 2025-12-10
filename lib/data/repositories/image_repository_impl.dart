import 'package:first_app/domain/entities/word_image.dart';
import 'package:first_app/domain/repositories/image_repository.dart';
import 'package:first_app/core/services/apiImage.dart';
import 'package:first_app/data/datasources/local/ImageDao.dart';
import 'package:first_app/data/models/image_model.dart';
import 'package:logger/logger.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageService _imageService;
  final ImageDao _imageDao;
  final Logger _logger = Logger();

  ImageRepositoryImpl({
    required ImageService imageService,
    required ImageDao imageDao,
  })  : _imageService = imageService,
        _imageDao = imageDao;

  @override
  Future<List<Map<String, dynamic>>> searchImages(String query) async {
    try {
      return await _imageService.getMinImg(query);
    } catch (e) {
      _logger.e('Error buscando imágenes: $e');
      return [];
    }
  }

  @override
  Future<List<int>> saveImages(
    List<Map<String, dynamic>> images,
    int wordId,
  ) async {
    List<int> savedIds = [];

    for (var imageData in images) {
      try {
        final imageModel = Image_Model(
          wordId: wordId,
          name: imageData['description'] ??
              imageData['alt_description'] ??
              'Sin nombre',
          author: (imageData['user'] is Map)
              ? imageData['user']['name']
              : imageData['user'] ?? 'Desconocido',
          url: imageData['url']['regular'],
          tinyurl: imageData['url']['thumb'],
          source: imageData['source'] ?? 'Desconocida',
        );

        final id = await _imageDao.insertImage(imageModel);
        savedIds.add(id);
      } catch (e) {
        _logger.e('Error guardando imagen: $e');
      }
    }

    return savedIds;
  }

  @override
  Future<List<WordImage>> getImagesByWordId(int wordId) async {
    // Implementar si necesitas obtener imágenes de una palabra
    throw UnimplementedError();
  }
}
