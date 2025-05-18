import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stockapp/data/user_stock_model.dart';

class StockService {
  static Future<List<UserStockModel>> fetchStockList(String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID is empty');
    }

    final url = Uri.parse('http://withyou.me:8080/user-info/$userId');

    try {
      final response = await http.get(url, headers: {'accept': '*/*'});

      if (response.statusCode == 200) {
        final data = utf8.decode(response.bodyBytes);  
        final decodedData = jsonDecode(data);  
        List<UserStockModel> stocks = (decodedData['stocks'] as List)
            .map((stock) => UserStockModel.fromJson(stock))
            .toList();

        return stocks;
      } else if (response.statusCode == 404) {
        throw Exception('User not found (404). Check your user ID or endpoint.');
      } else {
        throw Exception('Failed to load portfolio data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading stock data: $e');
    }
  }
}

