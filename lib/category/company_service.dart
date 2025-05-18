import 'dart:convert';
import 'package:http/http.dart' as http;
import 'stock_item.dart';

class CompanyService {
  static Future<List<StockItem>> fetchStockListByCategory(String category) async {
    final encodedCategory = Uri.encodeComponent(category);
    final url = 'http://withyou.me:8080/category/$encodedCategory/stock-list';

    final response = await http.get(Uri.parse(url));
    print('[요청 URL] $url');
    print('[상태코드] ${response.statusCode}');

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes); // 인코딩 문제 해결
      final List<dynamic> data = json.decode(decodedBody);
      return data.map((item) => StockItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load stock list');
    }
  }
}
