import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class TranslateService{
  //constructor privado para patron singleton
  static final TranslateService _instance= TranslateService._internal();
  factory TranslateService() => _instance;
  TranslateService._internal();
  final traslat_url=dotenv.env["TRANSL_URL"];

  Future<Map<String,dynamic>> translate(String text) async{
    try{
      final resp= await http.post(
        Uri.parse('$traslat_url'),
        headers: { 
          "Content-Type": "application/json"
        },
        body: {
          'q': text,
          "source": "en",
          "target": "es",
          "format": "text",
          "alternatives": 3,
          "api_key": ""
        }
      );
      if(resp.statusCode == 200){
        final data=jsonDecode(resp.body);
        return data;
      }else{
        throw Exception( 'Api error: ${resp.statusCode} - ${resp.body}');
      }
    }catch(e){
      throw Exception('failed to fetch response: $e');
    }
  }

}