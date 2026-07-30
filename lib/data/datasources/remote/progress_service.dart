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
}
