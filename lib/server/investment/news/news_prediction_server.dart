import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsPredictionService {
  static Future<String?> fetchPrediction(String stockName) async {
    final url = Uri.parse('http://withyou.me:8080/news/$stockName/prediction');

    //print("서버 요청 시작: $url");

    try {
      final response = await http.get(url, headers: {
        "accept": "*/*",
      });

      //print("응답 코드: ${response.statusCode}");

      
      final decodedBody = utf8.decode(response.bodyBytes);
      //print("응답 본문 (디코딩 후): $decodedBody");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(decodedBody);
        return data["predictedResult"] ?? "예측 결과를 가져올 수 없습니다.";
      } else {
        return "예측 데이터를 불러오는 데 실패했습니다.";
      }
    } catch (e) {
      //print("서버 요청 실패: $e");
      return "서버 연결 오류가 발생했습니다.";
    }
  }
}
