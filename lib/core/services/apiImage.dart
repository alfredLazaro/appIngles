import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal() {
    _init();
  }
  String? _apiKey;
  String? _basUrl;
  late Dio _dio;
  Future<void> _init() async {
    await dotenv.load(fileName: 'assets/.env');
    _apiKey = dotenv.env['KEY_UNS'];
    _basUrl = dotenv.env['URL_UNS'];
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception("API_KEY no encontrada en .env");
    }

    if (_basUrl == null || _basUrl!.isEmpty) {
      throw Exception("API_BASE_URL no encontrada en .env");
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: _basUrl!,
        connectTimeout: const Duration(seconds: 5), // Tiempo máximo de conexión
        receiveTimeout:
            const Duration(seconds: 3), // Tiempo máximo de respuesta
      ),
    );
  }

  Future<Map<String, dynamic>> getImg(String namImg) async {
    try {
      final response = await _dio.get('/search/photos',
          queryParameters: {'query': namImg},
          options: Options(headers: {'Authorization': 'Client-ID $_apiKey'}));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            "Unsplash API Error ${e.response?.statusCode}: ${e.response?.data}");
      } else {
        throw Exception("Network error: ${e.message}");
      }
    }
  }

  Future<List<Map<String, dynamic>>> getMinImg(String nImg) async {
    try {
      final response = await _dio.get('/search/photos',
          queryParameters: {
            'query': nImg,
            'page': '1',
            'per_page': '10', //solo quiero 10 results
          },
          options: Options(headers: {'Authorization': 'Client-ID $_apiKey'}));
      if (response.data['results'] == null ||
          (response.data['results'] as List).isEmpty) {
        throw Exception('No se encontraron imageners para "$nImg"');
      }
      final List<Map<String, dynamic>> images =
          (response.data['results'] as List).map((photo) {
        return {
          'id': photo['id'],
          'url': {
            'regular':
                photo['urls']?['regular'] ?? 'https://default-image-url.com',
            'small': photo['urls']?['small'] ?? 'https://default-image-url.com',
            'thumb': photo['urls']?['thumb'] ?? 'https://default-image-url.com',
          },
          'user': {'name': photo['user']?['name'] ?? 'Autor desconocido'},
          'alt_description': photo['alt_description'] ?? 'Imagen de $nImg',
        };
      }).toList();
      return images;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            "Unsplash API Error ${e.response?.statusCode}: ${e.response?.data}");
      } else {
        throw Exception("Network error: ${e.message}");
      }
    }
  }
}
