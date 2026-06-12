import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WordService {
  static final WordService _instance = WordService._internal();
  factory WordService() => _instance;
  WordService._internal();

  final baseUrl = dotenv.env['BASE_URL_DICTIONARY'];

  Future<Map<String, dynamic>> getWordDefinition(String word) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$word'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final Map<String, dynamic> json2 = jsonList[0];
        return {
          'definition': json2['meanings'][0]['definitions'][0]['definition'],
          'example': json2['meanings'][0]['definitions'][0]['example']
        };
      } else {
        throw Exception('Palabra no encontrada');
      }
    } catch (e) {
      throw Exception('Error al buscar la definición');
    }
  }

  Future<List<Map<String, dynamic>>> getAllMeanings(String word) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$word'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        if (jsonList.isEmpty) {
          return [];
        }

        final Map<String, dynamic> wordData = jsonList[0];
        final String phonetic = (wordData['phonetics'] as List<dynamic>)
                .map((p) => p['text'])
                .where((text) => text != null && text.isNotEmpty)
                .firstOrNull ??
            (wordData['phonetic'] as String?) ??
            '';
        final List<dynamic> meaningsJson = wordData['meanings'] ?? [];
        final List<Map<String, dynamic>> meanings =
            (meaningsJson).map((meaning) {
          final List<dynamic> definitions = meaning['definitions'] ?? [];
          return {
            'partOfSpeech': meaning['partOfSpeech'],
            'definitions': definitions.map((def) {
              return {
                'definition': def['definition'],
                'example': def['example'],
                'phonetic': phonetic,
              };
            }).toList(),
          };
        }).toList();

        return meanings;
      } else if (response.statusCode == 404) {
        throw Exception('Palabra no encontrada');
      } else {
        throw Exception('Error en la API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener significados: $e');
    }
  }
}
