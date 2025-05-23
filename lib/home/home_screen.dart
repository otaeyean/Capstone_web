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
import './recommended_stocks.dart';
import '../home/my_stock_news.dart';
import '../chatbot/chatbot_main_screen.dart';
import '../investment/investment_screen.dart';
import '../ranking/ranking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 기존 변수들 유지
  bool isLoggedIn = false;
  List<Map<String, String>> stockList = [];
  List<UserStockModel> _userStocks = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchStockList();
    _fetchUserStocks();
  }

  void refreshUserStocks() {
    _fetchUserStocks();
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

  void _onMenuTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildMenuItem(String title, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onMenuTap(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (_selectedIndex) {
      case 0:
        content = _buildHomeContent();
        break;
      case 1:
        content = InvestmentScreen();
        break;
      case 2:
        content = ChatbotScreen();
        break;
      case 3:
        content = RankingScreen();
        break;
      case 4:
        content = UserInfoScreen(key: GlobalKey<UserInfoScreenState>());
        break;
      default:
        content = _buildHomeContent();
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 248, 244),
      body: Row(
        children: [
          Container(
            width: 220,
            color: const Color.fromRGBO(50, 188, 133, 1),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "WithYou",
                  style: TextStyle(
                    fontFamily: 'MinSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                _buildMenuItem('홈', 0),
                _buildMenuItem('모의투자', 1),
                _buildMenuItem('챗봇', 2),
                _buildMenuItem('순위', 3),
                _buildMenuItem('내 정보', 4),
                const Spacer(),
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
                    style: const TextStyle(
                      fontFamily: 'MinSans',
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        if (isWide) {
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: ListView(
                  padding: const EdgeInsets.all(40),
                  children: [
                    StockListWidget(stocks: _userStocks),
                    const SizedBox(height: 40),
                    const UserNewsScreen(),
                    const SizedBox(height: 40),
                    RecommendedStocks(),
                  ],
                ),
              ),
              Container(
                width: 1,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(vertical: 40),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: StockRanking(),
                ),
              ),
            ],
          );
        } else {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              StockListWidget(stocks: _userStocks),
              const SizedBox(height: 20),
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 20),
              const UserNewsScreen(),
              const SizedBox(height: 20),
              RecommendedStocks(),
              const SizedBox(height: 20),
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 20),
              StockRanking(),
            ],
          );
        }
      },
    );
  }
}
