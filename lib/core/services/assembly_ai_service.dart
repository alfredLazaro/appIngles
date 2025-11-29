import 'dart:convert';
import 'package:http/http.dart' as http;

class AssemblyAIService {
  final String apiKey =
      '5dvcxzvsdf34349'; // ⚠️ Usa una variable de entorno en producción
  final String baseUrl = 'https://api.assemblyai.com/v2/transcript';

  // 🔹 Transcribir Audio
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
        print("✅ Transcripción enviada, ID: $transcriptId");

        return _getTranscriptText(transcriptId);
      } else {
        print("❌ Error en la petición: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error al llamar a AssemblyAI: $e");
      return null;
    }
  }

  // 🔹 Obtener la transcripción con polling
  Future<String?> _getTranscriptText(String transcriptId) async {
    final String transcriptUrl = "$baseUrl/$transcriptId";
    int attempts = 10; // Limitar intentos de verificación

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
            print("✅ Transcripción completada: ${data["text"]}");
            return data["text"];
          } else if (status == "failed") {
            print("❌ La transcripción falló.");
            return null;
          }
        } else {
          print("⚠️ Esperando transcripción...");
        }

        await Future.delayed(const Duration(seconds: 3));
        attempts--;
      }

      print("❌ No se pudo obtener la transcripción tras varios intentos.");
      return null;
    } catch (e) {
      print("❌ Error al obtener la transcripción: $e");
      return null;
    }
  }
}
