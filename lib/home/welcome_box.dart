import 'dart:async'; 
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '/login/login.dart';
import 'package:stockapp/user_info/user_info_screen.dart';

class WelcomeBox extends StatelessWidget {
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
      stream: Stream.periodic(Duration(seconds: 5)).asyncMap((_) => _fetchPortfolioData(userId)),
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
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Color(0xFF67CA98 ), borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, size: 30, color: Colors.grey)),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$userId 님', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 5),
                    Text('보유 금액: $balance', style: TextStyle(color: Colors.white)),
                    Text('수익률: $totalProfitRate', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

Future<Map<String, dynamic>> _fetchPortfolioData(String userId) async {
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

  Widget _buildLoginRequiredBox(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Color(0xFF67CA98), borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('로그인을 진행해주세요!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
            SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(radius: 30, backgroundColor: Colors.grey[800], child: Icon(Icons.person, size: 30, color: Colors.white)),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('총 자산: -', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('보유 주식: -', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
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
      decoration: BoxDecoration(color: Color(0xFF75BEA9), borderRadius: BorderRadius.circular(8.0)),
      child: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
