import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  String apiKey;
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  List<Map<String, String>> messages = [];

  ApiService(this.apiKey);

  void addMessage(String role, String content) {
    messages.add({'role': role, 'content': content});
  }

  Future<String> sendMessage(String message) async {
    addMessage('user', message);
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apiMessage = data['choices'][0]['message']['content'];
        addMessage('assistant', apiMessage);
        return apiMessage;
      } else {
        final error = jsonDecode(response.body);
        throw Exception('API Error: ${error['error']['message']}');
      }
    } catch (e) {
      throw Exception('Failed to communicate with the API: $e');
    }
  }
}
