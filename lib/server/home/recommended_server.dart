import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendedService {
  static Future<List<String>> fetchRecommendedCategories() async {
    final url = Uri.parse('http://withyou.me:8080/recommended-list');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data =
          json.decode(utf8.decode(response.bodyBytes));
      return data
          .map<String>((item) => item['categoryName'].toString())
          .toList();
    } else {
      throw Exception('추천 카테고리를 불러오는데 실패했습니다.');
    }
  }
}
