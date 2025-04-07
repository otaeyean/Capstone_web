import 'package:shared_preferences/shared_preferences.dart';

//UserInfoScreen에서 사용
class AuthService {
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
  }

  static Future<void> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', userId);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nickname'); // 저장된 유저 정보 삭제
  }
}
