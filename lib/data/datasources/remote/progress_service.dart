import 'package:dio/dio.dart';

class ProgressService {
  final Dio _dio;

  ProgressService({required String baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await _dio.post(
      '/auth/register',
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> pushProgress(
    List<Map<String, dynamic>> batch,
    String token,
  ) async {
    await _dio.put(
      '/progress',
      data: batch,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<List<dynamic>> pullProgress(String token) async {
    final response = await _dio.get(
      '/progress',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as List<dynamic>;
  }
  //solo para admin por si crece la lista de palabras en el futuro 
  Future<List<dynamic>> getAllWords(String token) async {
    final response = await _dio.get(
      '/words',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> getAllTranslations(String token) async {
    final response = await _dio.get(
      '/translations',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as List<dynamic>;
  }
  Future<List<dynamic>> getAllImages(String token) async {
    final response = await _dio.get(
      '/images',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as List<dynamic>;
  }

  //cargar por categorias, para que no sea tan pesado 
  Future<List<dynamic>> getWordsByCategory(String token, String category) async {
    final response = await _dio.get(
      '/words/category/$category',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as List<dynamic>;
  }
  // obtener traducciones por ids de palabras, para que no sea tan pesado
  Future<List<dynamic>> getTranslationsByWordsIds(String token, List<int> wordIds) async {
    final response = await _dio.post(
      '/translations/words',
      data: {'word_ids': wordIds},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> getImagesByWordsIds(String token, List<int> wordIds) async {
    final response = await _dio.post(
      '/images/words',
      data: {'word_ids': wordIds},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as List<dynamic>;
  }
}
