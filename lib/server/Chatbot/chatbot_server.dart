import 'package:http/http.dart' as http;

class ChatbotService {
  
  Future<String> sendMessage(String message, String userId) async {
    final url = Uri.parse('http://withyou.me:8080/chatbot/ask?message=${Uri.encodeComponent(message)}&username=$userId');
    print('Request URL: $url'); 

    try {
      final response = await http.get(url);
      print('Response Status Code: ${response.statusCode}');  
      print('Response Body: ${response.body}');  

      if (response.statusCode == 200) {
        return response.body;  
      } else {
        print('Server Error: ${response.statusCode}');  
        return '서버와 연결할 수 없습니다.';
      }
    } catch (error) {
      print('Network Error: $error'); 
      return '네트워크 오류가 발생했습니다.';
    }
  }
}
