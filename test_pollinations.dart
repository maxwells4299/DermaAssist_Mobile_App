import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final response = await http.post(
    Uri.parse('https://text.pollinations.ai/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'messages': [
        {'role': 'system', 'content': 'You are a helpful AI.'},
        {'role': 'user', 'content': 'Hello, what is your name?'}
      ]
    }),
  );
  print(response.statusCode);
  print(response.body);
}
