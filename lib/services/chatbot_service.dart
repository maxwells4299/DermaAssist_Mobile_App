import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  // Replace this with your actual Gemini API Key from Google AI Studio.
  // Example: 'AIzaSyA...'
  static const String _apiKey = 'AIzaSyCOEtpfA_n739iqg_vjWJdfOXokmkgQPvU';
  static const String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$_apiKey';

  ChatbotService();

  Future<String> sendMessage(String text) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return "Hello! I am your AI medical assistant. To start chatting, please add your Gemini API Key in the ChatbotService.";
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {
                'text': 'You are a highly capable, empathetic, and comprehensive medical AI assistant. Your goal is to answer EVERY question the patient asks, including personal or detailed medical questions, in a way that is robust, thorough, and easy for any patient to understand. Break down complex medical terms into simple analogies. Be kind and direct. While you specialize in the DermaAssist application, B-RMMS algorithm, and Melanoma screening, you should also be extremely helpful regarding any other concerns the patient shares. Always make sure to remind them politely that you are an AI and they should consult a physician for formal diagnoses.'
              }
            ]
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': text}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['candidates'][0]['content']['parts'][0]['text'].toString().trim();
        return answer;
      } else {
        return "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "Something went wrong while trying to reach the AI. Please verify your internet connection and make sure your API key is correct. Details: $e";
    }
  }
}
