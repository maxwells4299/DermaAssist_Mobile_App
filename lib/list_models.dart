import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'AIzaSyCOEtpfA_n739iqg_vjWJdfOXokmkgQPvU';
  final url = 'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey';
  
  final response = await http.get(Uri.parse(url));
  print(response.body);
}
