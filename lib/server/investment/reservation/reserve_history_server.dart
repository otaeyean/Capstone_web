import 'dart:convert';
import 'package:http/http.dart' as http;

class ReserveHistoryService {
  static const String baseUrl = 'http://withyou.me:8080/stock/reserve/history';

  // 서버에서 예약 내역을 가져오는 메소드
  static Future<List<dynamic>> fetchReserveHistory(String userId) async {
    final url = Uri.parse('$baseUrl/$userId');  
    try {
      final response = await http.get(url, headers: {'accept': '*/*'});

      if (response.statusCode == 200) {

        List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('예약 내역을 가져오는 데 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('서버 요청 중 오류가 발생했습니다: $e');
    }
  }
}
