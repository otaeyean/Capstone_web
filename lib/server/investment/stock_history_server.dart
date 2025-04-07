import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderHistoryService {
  static Future<List<dynamic>> fetchOrderHistory(String userId) async {
    String url = "http://withyou.me:8080/stock/history/$userId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load order history");
      }
    } catch (e) {
      print("Error: $e");
      return []; // 오류 발생 시 빈 리스트 반환
    }
  }
}
