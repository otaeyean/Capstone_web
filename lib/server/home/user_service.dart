import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static Future<Map<String, dynamic>> fetchPortfolioData(String userId) async {
    try {
      final response = await http.get(Uri.parse('http://withyou.me:8080/user-info/$userId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        int balance = (data['balance'] as double).toInt();

        return {
          'balance': balance,
          'totalProfitRate': data['totalProfitRate']
        };
      } else {
        throw Exception('Failed to load portfolio data');
      }
    } catch (e) {
      throw Exception('Error fetching portfolio data: $e');
    }
  }
}
