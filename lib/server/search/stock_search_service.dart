import 'dart:convert';
import 'package:http/http.dart' as http;

class StockSearchService {
  static const String apiUrl = 'http://withyou.me:8080/stock-list'; // 실제 API URL로 변경

  // 검색어에 맞는 주식 목록을 가져오는 함수
  Future<List<Map<String, String>>> searchStocks(String query) async {
    try {
      // 한글을 URL에 안전하게 전달하기 위해 encodeComponent 사용
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http.get(Uri.parse('$apiUrl?query=$encodedQuery'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Map<String, dynamic>을 Map<String, String>으로 변환
        return data.map((item) {
          return {
            'stockCode': item['stockCode'].toString(),
            'stockName': item['stockName'].toString(),
          };
        }).toList();
      } else {
        throw Exception('Failed to load stocks');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
