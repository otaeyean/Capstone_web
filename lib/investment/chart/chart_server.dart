import 'dart:convert';
import 'package:http/http.dart' as http;
import 'stock_price.dart';

class ChartService {
  static const String baseUrl = "http://withyou.me:8080";

  Future<List<StockPrice>> fetchChartData(String stockCode, {String period = "D"}) async {
    final url = Uri.parse("$baseUrl/prices/$stockCode?period=$period");
  

    try {
      final response = await http.get(url);
 
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => StockPrice.fromJson(data)).toList();
      } else {
        throw Exception("Failed to load stock prices: ${response.statusCode}");
      }
    } catch (e) {
  
      throw Exception("Error fetching stock data: $e");
    }
  }

  // ✅ 1분봉 데이터 가져오는 함수 추가
  Future<List<StockPrice>> fetchMinuteChartData(String stockCode, {int time = 1}) async {
    final url = Uri.parse("$baseUrl/prices-today/$stockCode?time=$time");
 

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => StockPrice.fromJsonMinute(data)).toList();
      } else {
        throw Exception("Failed to load minute stock prices: ${response.statusCode}");
      }
    } catch (e) {

      throw Exception("Error fetching 1-minute stock data: $e");
    }
  }
}
