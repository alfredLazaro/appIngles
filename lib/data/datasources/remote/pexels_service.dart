import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

class PexelsService {
  static final PexelsService _instance = PexelsService._internal();
  factory PexelsService() => _instance;

  late final String _apiKey;
  late final String _baseUrl;
  late final Dio _dio;

  PexelsService._internal() {
    _apiKey = dotenv.env['KEY_PEX'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('KEY_PEX no encontrada en .env');
    }

    _baseUrl = dotenv.env['URL_PEX'] ?? '';
    if (_baseUrl.isEmpty) {
      throw Exception('URL_PEX no encontrada en .env');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );
  }

  Future<Map<String, dynamic>> getImg(String namImg) async {
    try {
      final response = await _dio.get('/search',
          queryParameters: {'query': namImg},
          options: Options(headers: {'Authorization': _apiKey}));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            "Pexels API Error ${e.response?.statusCode}: ${e.response?.data}");
      } else {
        throw Exception("Network error: ${e.message}");
      }
    }
  }

  Future<List<Map<String, dynamic>>> getMinImg(String nImg) async {
    try {
      final response = await _dio.get('/search',
          queryParameters: {
            'query': nImg,
            'page': '1',
            'per_page': '12',
          },
          options: Options(headers: {'Authorization': _apiKey}));
      if (response.data['photos'] == null ||
          (response.data['photos'] as List).isEmpty) {
        throw Exception('No se encontraron imágenes para "$nImg"');
      }
      final List<Map<String, dynamic>> images =
          (response.data['photos'] as List).map((photo) {
        return {
          'id': photo['id'].toString(),
          'url': {
            'regular':
                photo['src']?['large'] ?? 'https://default-image-url.com',
            'small':
                photo['src']?['medium'] ?? 'https://default-image-url.com',
            'thumb':
                photo['src']?['tiny'] ?? 'https://default-image-url.com',
          },
          'user': {'name': photo['photographer'] ?? 'Autor desconocido'},
          'alt_description': photo['alt'] ?? 'Pexels',
        };
      }).toList();
      return images;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            "Pexels API Error ${e.response?.statusCode}: ${e.response?.data}");
      } else {
        throw Exception("Network error: ${e.message}");
      }
    }
  }
}