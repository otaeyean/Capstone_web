import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stockapp/home/news_model.dart';

class NewsApi {
  static Future<List<NewsItem>> fetchUserNews(String userId, {String category = "주식 주가"}) async {
    final encodedCategory = Uri.encodeComponent(category);
    final url = Uri.parse("http://withyou.me:8080/news/user/$userId?category=$encodedCategory");

    print("✅ 뉴스 요청 URL: $url");

    try {
      final response = await http.get(url);
      print("✅응답 상태 코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); 
        print("✅ UTF-8 디코딩된 응답 본문: $decodedBody");

        final List<dynamic> data = json.decode(decodedBody);

        print("✅ 뉴스 항목 개수: ${data.length}");
        if (data.isNotEmpty) {
          print("✅ 첫 뉴스 제목: ${data[0]['title']}");
        }

        return data.map((e) => NewsItem.fromJson(e)).toList();
      } else {
        throw Exception('뉴스 요청 실패: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("✅ 예외 발생: $e");
      rethrow;
    }
  }
}
