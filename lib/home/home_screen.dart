import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../user_info/user_info_screen.dart';
import 'stock_list_widget.dart';
import 'stock_ranking.dart';
import 'welcome_box.dart';
import '/login/login.dart';
import 'searchable_stock_list.dart';
import 'package:stockapp/data/user_stock_model.dart';
import 'package:stockapp/server/userInfo/stock_service.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedIn = false;
  List<Map<String, String>> stockList = [];
  List<UserStockModel> _userStocks = []; // ✅ 실제 보유 종목 리스트

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchStockList();
    _fetchUserStocks(); // ✅ 종목 불러오기 호출
  }

  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.containsKey('nickname');
    });
  }

  _fetchStockList() async {
    final response = await http.get(Uri.parse('http://withyou.me:8080/stock-list'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        stockList = data.map((item) => {
          'stockCode': item['stockCode'].toString(),
          'stockName': utf8.decode(item['stockName'].codeUnits),
        }).toList();
      });
    } else {
      throw Exception('Failed to load stock list');
    }
  }

  Future<void> _fetchUserStocks() async {
    final userId = await AuthService.getUserId();
    if (userId != null && userId.isNotEmpty) {
      final stocks = await StockService.fetchStockList(userId);
      setState(() {
        _userStocks = stocks;
      });
    }
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('nickname');
    await prefs.remove('balance');
    setState(() {
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "WithYou",
            style: TextStyle(fontFamily: 'MinSans', fontWeight: FontWeight.w800),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF67CA98 ),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              if (isLoggedIn) {
                _logout();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ).then((_) => _checkLoginStatus());
              }
            },
            child: Text(
              isLoggedIn ? "로그아웃" : "로그인",
              style: TextStyle(fontFamily: 'MinSans', fontWeight: FontWeight.w900, color: Colors.black),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SearchableStockList(stockList: stockList),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: WelcomeBox(),
            ),
            SizedBox(height: 20),
            if (isLoggedIn && _userStocks.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserInfoScreen()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bar_chart, color: Color(0xFF03314B ) ),
                          SizedBox(width: 8),
                          Text(
                            "내 종목보기",
                            style: TextStyle(
                              fontFamily: 'MinSans', 
                              fontWeight: FontWeight.w900, 
                              fontSize: 18, 
                              color: Color(0xFF03314B)
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF03314B ) ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: StockListWidget(stocks: _userStocks),
                ),
              ),
              SizedBox(height: 5),
            ],
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    "주식 랭킹", 
                    style: TextStyle(
                      fontFamily: 'MinSans', 
                      fontWeight: FontWeight.w900, 
                      fontSize: 18,
                      color: Color(0xFF03314B) // 텍스트 색상 추가
                    )
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 450,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: StockRanking(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
