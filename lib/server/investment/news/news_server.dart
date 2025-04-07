import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class NewsService {
  static Future<List<Map<String, dynamic>>> fetchNews(String stockName) async {
    final String encodedStockName = Uri.encodeComponent(stockName);
    final url =
        'http://withyou.me:8080/news/$encodedStockName?category=주식%20주가&page=1';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonData = json.decode(decodedBody);

        List<Map<String, dynamic>> validArticles = [];

        for (var article in jsonData) {
          try {
            if (article is Map<String, dynamic> &&
                article['title'] != null &&
                article['link'] != null &&
                article['link'].startsWith('http')) {
              validArticles.add({
                'title': parse(article['title']).body!.text,
                'summary': parse(article['summary'] ?? '').body!.text,
                'link': article['link'],
                'imageUrl': article['imageUrl'] ?? '',
              });
            }
          } catch (e) {
            //print('❌ 뉴스 변환 오류: $e');
          }
        }

        return validArticles;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
