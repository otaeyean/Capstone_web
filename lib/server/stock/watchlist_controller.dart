import 'package:http/http.dart' as http;
import 'dart:convert';

class WatchListController {
  final String baseUrl;

  WatchListController({required this.baseUrl});

  // 관심 목록 추가
  Future<void> addStockToWatchlist(String userId, String stockCode) async {
    final url = Uri.parse('$baseUrl/watchlist/add');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'stockCode': stockCode,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add stock to watchlist');
    }
  }

  // 관심 목록에서 삭제
  Future<void> removeStockFromWatchlist(String userId, String stockCode) async {
    final url = Uri.parse('$baseUrl/watchlist/remove');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'stockCode': stockCode,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove stock from watchlist');
    }
  }

  // 관심 목록 조회
  Future<List<Map<String, dynamic>>> getWatchlist(String userId) async {
    final url = Uri.parse('http://withyou.me:8080/watchlist/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Failed to load watchlist');
    }
  }
}