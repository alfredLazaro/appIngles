import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/domain/entities/image_search_result.dart';
import 'package:first_app/domain/entities/word_image.dart';
import 'package:first_app/domain/repositories/image_repository.dart';
import 'package:first_app/data/datasources/remote/unsplash_service.dart';
import 'package:first_app/data/datasources/remote/pexels_service.dart';
import 'package:first_app/data/datasources/local/ImageDao.dart';
import 'package:first_app/data/models/image_model.dart';
import 'package:first_app/data/mappers/image_mapper.dart';
import 'package:logger/logger.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageService _imageService;
  final PexelsService _pexelsService;
  final ImageDao _imageDao;
  final Logger _logger = Logger();

  ImageRepositoryImpl({
    required ImageService imageService,
    required PexelsService pexelsService,
    required ImageDao imageDao,
  })  : _imageService = imageService,
        _pexelsService = pexelsService,
        _imageDao = imageDao;

  @override
  Future<List<ImageSearchResult>> searchImages(String query) async {
    final results = await Future.wait([
      _imageService.getMinImg(query).catchError((e) {
        _logger.e('Error buscando en Unsplash: $e');
        return <Map<String, dynamic>>[];
      }),
      _pexelsService.getMinImg(query).catchError((e) {
        _logger.e('Error buscando en Pexels: $e');
        return <Map<String, dynamic>>[];
      }),
    ]);

    final rawImages = [...results[0], ...results[1]];
      return rawImages.map((map) => ImageSearchResult(
            id: map['id'] as String,
            regularUrl: (map['url'] as Map)['regular'] as String,
            thumbUrl: (map['url'] as Map)['thumb'] as String,
            author: (map['user'] is Map)
                ? (map['user'] as Map)['name'] as String
                : (map['user'] as String?) ?? 'Desconocido',
            description: (map['alt_description'] as String?) ?? 'Unsplash',
          )).toList();
    
  }

  @override
  Future<List<int>> saveImages(
    List<ImageSearchResult> images,
    int wordId,
  ) async {
    List<int> savedIds = [];

    for (final image in images) {
      try {
        final imageModel = Image_Model(
          wordId: wordId,
          name: image.description,
          author: image.author,
          url: image.regularUrl,
          tinyurl: image.thumbUrl,
          source: image.description,
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
    try {
      final imageModels = await _imageDao.getByWordId(wordId);
      return imageModels.map((m) => ImageMapper.toWordImage(m)).toList();
    } catch (e) {
      _logger.e('Error obteniendo imágenes para wordId $wordId: $e');
      return [];
    }
  }

  @override
  Future<Map<int, List<FlashcardImage>>> getImagesByWordIds(
      List<int> wordIds) async {
    try {
      final imagesMap = await _imageDao.getImagesByWordIds(wordIds);
      return ImageMapper.mapToFlashcardImages(imagesMap);
    } catch (e) {
      _logger.e('Error guardando imagen: $e');
      return {};
    }
  }
}
