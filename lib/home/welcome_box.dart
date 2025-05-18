import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/login/login.dart';
import 'package:stockapp/user_info/user_info_screen.dart';
import 'package:stockapp/server/home/user_service.dart'; // ✅ 서버 요청 분리 후 추가

class WelcomeBox extends StatelessWidget {
  final Stream<Map<String, dynamic>>? _userStream;

  WelcomeBox({Key? key})
      : _userStream = _createUserStream(),
        super(key: key);

  static Stream<Map<String, dynamic>>? _createUserStream() {
    return Stream.periodic(Duration(seconds: 5)).asyncMap((_) async {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('nickname');
      if (userId == null) throw Exception('로그인 필요');
      return UserService.fetchPortfolioData(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingWidget();
        } else if (snapshot.hasError || !snapshot.hasData) {
          return _buildLoginRequiredBox(context);
        } else {
          final userId = snapshot.data!;
          return _buildUserInfoStream(context, userId);
        }
      },
    );
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname');
  }

  Widget _buildUserInfoStream(BuildContext context, String userId) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _userStream,
      builder: (context, snapshot) {
        String balance = '로딩 중...';
        String totalProfitRate = '로딩 중...';

        if (snapshot.hasData) {
          balance = '${snapshot.data!['balance']} 원';
          totalProfitRate = '${snapshot.data!['totalProfitRate']} %';
        } else if (snapshot.hasError) {
          balance = '수익률 오류';
          totalProfitRate = '수익률 오류';
        }

        return _buildUserInfoBox(context, userId, balance, totalProfitRate);
      },
    );
  }

  Widget _buildUserInfoBox(BuildContext context, String userId, String balance, String totalProfitRate) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoScreen()));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.lightGreen[200],
                    border: Border.all(
                      color: Colors.green[800]!,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.person_outline, size: 32, color: Colors.green[800]),
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$userId 님',
                      style: TextStyle(fontFamily: 'MinSans', fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 18),
                        SizedBox(width: 6),
                        Text('보유 금액: $balance', style: TextStyle(fontFamily: 'Paperlogy', fontSize: 18)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.trending_up, size: 18),
                        SizedBox(width: 6),
                        Text('수익률: $totalProfitRate', style: TextStyle(fontFamily: 'Paperlogy', fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequiredBox(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9), // ✅ 로그인 안된 상태도 같은 배경
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('로그인이 필요합니다!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person_outline, size: 32, color: Colors.grey[800])),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('총 자산: -', style: TextStyle(fontWeight: FontWeight.w900)),
                    Text('보유 주식: -', style: TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingWidget() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // ✅ 로딩도 같은 배경
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 3),
        ),
      ),
    );
  }
}
