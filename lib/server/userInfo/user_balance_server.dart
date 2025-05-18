import 'dart:convert';
import 'package:http/http.dart' as http;

class UserBalanceService {
  final String baseUrl = "http://withyou.me:8080/user-info";

  // 금액 업데이트 메서드
  Future<bool> updateBalance(String userId, double balance) async {
    final url = Uri.parse("$baseUrl/$userId/balance");

    //print(" ✅ 서버 요청 URL: $url");
    //print(" ✅ 전송 데이터: $balance");

    try {
      final response = await http.put(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(balance), 
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        //print("✅ 금액 업데이트 성공: $balance 원");
        return true;
      } else {
        //print("❌ 서버 오류: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      //print("❌ 네트워크 오류: $e");
      return false;
    }
  }

  // 금액 초기화 메서드
  Future<bool> resetBalance(String userId) async {
    final url = Uri.parse("$baseUrl/$userId/reset");

    //print("✅ 서버 요청 URL: $url");

    try {
      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
        },
        body: '', 
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        //print("✅ 금액 초기화 성공");
        return true;
      } else {
        //print("❌ 서버 오류: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      //print("❌ 네트워크 오류: $e");
      return false;
    }
  }
}
