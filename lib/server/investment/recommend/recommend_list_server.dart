// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendListServer {
  // 오늘의 카테고리 데이터 가져오기
  Future<List<String>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://withyou.me:8080/recommended-list'),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);
      return data.map((item) => item['categoryName'].toString()).toList();
    } else {
      throw Exception('Failed to load today categories: ${response.statusCode}');
    }
  }

  // 전체 카테고리 리스트 가져오기
  Future<List<String>> fetchAllCategories() async {
    final response = await http.get(
      Uri.parse('http://withyou.me:8080/category-list'),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);
      return data.map((item) => item['categoryName'].toString()).toList();
    } else {
      throw Exception('Failed to load all categories: ${response.statusCode}');
    }
  }
}
