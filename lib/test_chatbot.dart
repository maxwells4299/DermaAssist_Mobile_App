import 'services/chatbot_service.dart';

void main() async {
  print('Testing Gemini API ChatbotService...');
  final service = ChatbotService();
  
  print('Sending message: "What happens if I forget to wear sunscreen today?"');
  final response = await service.sendMessage('What happens if I forget to wear sunscreen today?');
  
  print('\n--- Response ---');
  print(response);
  print('----------------');
}
