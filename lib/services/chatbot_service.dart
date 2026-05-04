import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String _apiUrl = 'https://text.pollinations.ai/';

  ChatbotService();

  Future<String> sendMessage(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'messages': [
            {
              'role': 'system',
              'content': 'You are a highly capable, empathetic, and comprehensive medical AI assistant. Your goal is to answer EVERY question the patient asks, including personal or detailed medical questions, in a way that is robust, thorough, and easy for any patient to understand. Break down complex medical terms into simple analogies. Be kind and direct. While you specialize in the DermaAssist application, B-RMMS algorithm, and Melanoma screening, you should also be extremely helpful regarding any other concerns the patient shares. Always make sure to remind them politely that you are an AI and they should consult a physician for formal diagnoses. IMPORTANT: Do not use any special formatting characters like *, -, |, or # in your response. Provide your answer in plain text only.'
            },
            {
              'role': 'user',
              'content': text
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        // Sanitize the response to remove any stray special characters
        String sanitizedBody = response.body.replaceAll(RegExp(r'[*|#\-`]'), '');
        return sanitizedBody.trim();
      } else {
        return "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "Something went wrong while trying to reach the AI. Please verify your internet connection. Details: $e";
    }
  }
}
