import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepSeekApiService {
  DeepSeekApiService._privateConstructor();
  static final DeepSeekApiService _instance = DeepSeekApiService._privateConstructor();
  
  factory DeepSeekApiService() {
    return _instance;
  }
  static late final String _apiKey; 
  static late final String _apiUrl;
  Future<void> initialize() async {
    await dotenv.load(fileName: "assets/.env");
    _apiKey = dotenv.env['API_DEE'] ?? _throwEnvError('API_DEE');
    _apiUrl = dotenv.env['URL_D'] ?? _throwEnvError('URL_D');
    //print("API URL: $_apiUrl"); // Debug
  }

  Never _throwEnvError(String key) {
    throw Exception('La variable de entorno $key no está definida en .env');
  }
  Future<String> getChatResponse(String userMessage) async {

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'user', 'content': userMessage},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch response: $e');
    }
  }
}