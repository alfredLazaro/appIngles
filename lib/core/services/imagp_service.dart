import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

class ImagpService {
  static final ImagpService _instance = ImagpService._internal();
  factory ImagpService() => _instance;
  ImagpService._internal() {
    _init();
  }
  String? _apiKey;
  String? _basUrl;
  late Dio _dio;
  Future<void> _init() async {
    await dotenv.load(fileName: 'assets/.env');
    _apiKey = dotenv.env['KEY_PEX'];
    _basUrl = dotenv.env['URL_PEX'];
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

  /* Future<List<Map<String, dynamic>>> getImages(String nImg) async {
    try {
      final response = await _dio.get('/search/photos',
          queryParameters: {
            'query': nImg,
            'page': '1',
            'per_page': '6', //solo quiero 6 results
          },
          options: Options(headers: {'Authorization': 'Client-ID $_apiKey'}));
      //poner condicional si la respuesta esta vacia o hay error
      if (response == null) return [];
      final List<Map<String, dynamic>> images =
          (response.data['results'] as List).map((photo) {
        return {
          'url': {
            'regular':
                photo['src']?['medium'] ?? 'https://default-image-url.com',
            'small': photo['src']?['small'] ?? 'https://default-image-url.com',
            'thumb': photo['src']?['tiny'] ?? 'https://default-image-url.com',
          },
          'user': {
            'name': photo['user']?['photographer'] ?? 'Autor desconocido'
          },
          'alt_description': 'Pexels',
        };
      }).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            "Pexels API Error ${e.response?.statusCode}: ${e.response?.data}");
      } else {
        throw Exception("Network error: ${e.message}");
      }
    }
  } */
}
