import 'package:http/http.dart' as http;
import 'dart:convert';

class StockChartService {
  static Future<List<dynamic>> fetchChartData(String stockCode, String period) async {
    final url = 'http://withyou.me:8080/prices/$stockCode?period=$period';
    print('✅요청 URL: $url');
    
    final response = await http.get(Uri.parse(url));
  
    print('✅응답 상태 코드: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅응답 본문: ${response.body}');
      return json.decode(response.body);
    } else {
      print('✅주식 차트 데이터 로드 실패');
      throw Exception('주식 차트 데이터 로드 실패');
    }
  }
}
