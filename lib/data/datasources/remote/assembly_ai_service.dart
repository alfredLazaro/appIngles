import 'dart:convert';
import 'package:http/http.dart' as http;

class AssemblyAIService {
  final String apiKey =
      '5dvcxzvsdf34349';
  final String baseUrl = 'https://api.assemblyai.com/v2/transcript';

  Future<String?> transcribeAudio(String audioUrl) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"audio_url": audioUrl}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transcriptId = data["id"];

        return _getTranscriptText(transcriptId);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> _getTranscriptText(String transcriptId) async {
    final String transcriptUrl = "$baseUrl/$transcriptId";
    int attempts = 10;

    try {
      while (attempts > 0) {
        final response = await http.get(
          Uri.parse(transcriptUrl),
          headers: {"Authorization": "Bearer $apiKey"},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status = data["status"];

          if (status == "completed") {
            return data["text"];
          } else if (status == "failed") {
            return null;
          }
        }

        await Future.delayed(const Duration(seconds: 3));
        attempts--;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
