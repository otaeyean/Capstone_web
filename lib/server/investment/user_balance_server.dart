import 'dart:convert';
import 'package:http/http.dart' as http;

class UserBalanceService {
  final String baseUrl = "http://withyou.me:8080/user-info";

  Future<double?> fetchBalance(String userId) async {
    final url = Uri.parse("$baseUrl/$userId");
    //print("✅ 서버 요청 URL: $url");
    try {
      final response = await http.get(url, headers: {'accept': '*/*'});
      //print("✅ 서버 응답 코드: \${response.statusCode}");
      //print("✅ 서버 응답 본문: \${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['balance']?.toDouble();
      } else {
        //print("❌ 서버 오류: \${response.statusCode} \${response.body}");
        return null;
      }
    } catch (e) {
      //print("❌ 네트워크 오류: $e");
      return null;
    }
  }
}
