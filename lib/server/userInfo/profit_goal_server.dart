import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfitGoalService {
  static const _profitGoalKey = 'profitGoal';
  static Future<bool> updateProfitGoal(String userId, double newGoal) async {
    final url = Uri.parse('http://withyou.me:8080/user-info/$userId/profit-goal');
    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode(newGoal);

    print('📤 [요청 정보]');
    print('PUT $url');
    print('Headers: $headers');
    print('Body: $body');

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body,
      );

      print('📥 [응답 정보]');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      return response.statusCode == 204;
    } catch (e) {
      print('❌ [예외 발생]');
      print('Error: $e');
      return false;
    }
  }
  
  // 사용자가 설정한 목표 수익률 저장
  static Future<void> saveProfitGoal(double goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_profitGoalKey, goal);  // 목표 수익률 저장
  }

  // 사용자가 설정한 목표 수익률 불러오기
  static Future<double> loadProfitGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_profitGoalKey) ?? 0.0;  // 없으면 0.0으로 초기화
  }
  
  static Future<double?> getAchievementRate(String userId) async {
    final url = Uri.parse('http://withyou.me:8080/user-info/$userId/profit-goal/achievement-rate');
    final headers = {
      'accept': '*/*',
    };

    print('📤 [달성률 요청 정보]');
    print('GET $url');
    print('Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      print('📥 [달성률 응답 정보]');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final achievementRate = double.tryParse(response.body);
        if (achievementRate != null) {
          return achievementRate;
        } else {
          print('⚠️ 응답 데이터를 double로 변환하지 못했습니다.');
        }
      } else {
        print('⚠️ 서버로부터 오류 응답을 받았습니다.');
      }
    } catch (e) {
      print('❌ [예외 발생]');
      print('Error: $e');
    }

    return null;
  }
}
