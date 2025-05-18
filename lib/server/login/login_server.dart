import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>> login(String nickname, String password) async {
    final url = Uri.parse('http://withyou.me:8080/login');
    final body = jsonEncode({
      "userId": nickname,
      "password": password,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {'success': true, 'message': responseBody['message'], 'balance': responseBody['balance']};
      } else {
        final error = jsonDecode(response.body)['message'] ?? '로그인 실패!';
        return {'success': false, 'message': error};
      }
    } catch (e) {
      return {'success': false, 'message': '로그인에 실패했습니다. 닉네임과 비밀번호를 확인해주세요'};
    }
  }
}
