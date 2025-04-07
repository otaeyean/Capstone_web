import 'dart:convert';
import 'package:http/http.dart' as http;

// API 데이터 가져오기 함수
Future<List<Map<String, dynamic>>> fetchStockData(String endpoint, {String period = "DAILY"}) async {
  final baseUrl = "http://withyou.me:8080";
  final url = Uri.parse("$baseUrl/$endpoint?period=$period");

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes); 
      List<dynamic> data = json.decode(decodedBody);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      print("Failed to fetch stock data. Error: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("Error fetching stock data: $e");
    return [];
  }
}