import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PortfolioService {
  static Future<Map<String, dynamic>> fetchPortfolioData(String userId) async {
    final url = Uri.parse('http://withyou.me:8080/user-info/$userId');
    //print("✅서버 요청 보낸 url: $url");

    try {
      final response = await http.get(url, headers: {'accept': '*/*'});
      //print("✅응답 코드: ${response.statusCode}");
      //print("✅바디부분: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        //print("✅가져오기 실패함. Status code: ${response.statusCode}");
        throw Exception('Failed to load portfolio data');
      }
    } catch (e) {
      //print("✅Exception caught during GET request: $e");
      rethrow;
    }
  }
}
