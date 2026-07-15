import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/domain/entities/related_word.dart';

class DatamuseService {
  static final DatamuseService _instance = DatamuseService._internal();
  factory DatamuseService() => _instance;
  DatamuseService._internal();

  final String _baseUrl = dotenv.env['DATAMUSE_API'] ?? '';

  Future<List<RelatedWord>> getMeansLike(String word) async {
    try {
      final uri = Uri.parse('${_baseUrl}words')
          .replace(queryParameters: {'ml': word, 'max': '9'});
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Datamuse API error: ${response.statusCode}');
      }

      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((item) {
        final tags = (item['tags'] as List<dynamic>?)
                ?.map((t) => t as String)
                .toList() ??
            [];
        return RelatedWord(
          word: item['word'] as String,
          tags: tags,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener palabras similares: $e');
    }
  }
}
