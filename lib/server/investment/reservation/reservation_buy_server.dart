import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> reserveStock(String userId, String stockCode, int quantity, double targetPrice) async {
  final url = Uri.parse('http://withyou.me:8080/stock/reserve/buy');
  final headers = {
    'Content-Type': 'application/json',
    'accept': '*/*',
  };
  final body = jsonEncode({
    'userId': userId,
    'stockCode': stockCode,
    'quantity': quantity,
    'targetPrice': targetPrice.toInt(),
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;  
    } else {
      return false;  
    }
  } catch (e) {
    return false; 
  }
}
