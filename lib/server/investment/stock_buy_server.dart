import 'dart:convert';
import 'package:http/http.dart' as http;

class StockServer {
  static const String baseUrl = 'http://withyou.me:8080/stock';

  /// 주식 가격을 가져오는 메서드
  static Future<double?> fetchStockPrice(String stockCode) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/price/$stockCode'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['price']?.toDouble();
      } else {
        print("[에러] 주식 가격 불러오기 실패: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("[에러] 서버 요청 실패: $e");
      return null;
    }
  }

  /// 주식을 구매하는 메서드
  static Future<bool> buyStock(String userId, String stockCode, int quantity) async {
    try {
      Map<String, dynamic> requestBody = {
        "userId": userId,
        "stockCode": stockCode,
        "quantity": quantity,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/buy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("[서버 응답] ${response.statusCode}: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("[에러] 서버 요청 실패: $e");
      return false;
    }
  }
}
