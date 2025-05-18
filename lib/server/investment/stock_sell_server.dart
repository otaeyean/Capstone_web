import 'package:http/http.dart' as http;
import 'dart:convert';

class StockServer {
  static Future<bool> sellStock(String userId, String stockCode, int quantity) async {
    final url = Uri.parse('http://withyou.me:8080/stock/sell');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "userId": userId,
        "stockCode": stockCode,
        "quantity": quantity,
      }),
    );

    return response.statusCode == 200;
  }
}

