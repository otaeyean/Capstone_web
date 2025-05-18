import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockapp/ranking/ranking_screen.dart';
import 'home/home_screen.dart'; // 반드시 HomeScreen이 StatefulWidget이어야 함
import 'investment/investment_screen.dart';
import 'chatbot/chatbot_main_screen.dart';
import 'user_info/user_info_screen.dart';
import 'investment/chart/stock_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StockProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WithYou모바일',
      theme: ThemeData(
        fontFamily: 'NotoSans',
        primarySwatch: Colors.blue,
        canvasColor: Colors.white,
        scaffoldBackgroundColor: Color(0xFFFFFFFF),
      ),
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final GlobalKey<UserInfoScreenState> _userInfoKey = GlobalKey<UserInfoScreenState>();
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>(); // ✅ 정확한 타입 사용

  late final List<Widget> _pages = [
    HomeScreen(key: _homeKey),            // ✅ Key 설정
    InvestmentScreen(),
    ChatbotScreen(),
    RankingScreen(),
    UserInfoScreen(key: _userInfoKey),    // ✅ Key 설정
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      _homeKey.currentState?.refreshUserStocks();   // ✅ 홈 갱신
    } else if (index == 4) {
      _userInfoKey.currentState?.refreshStock();    // ✅ 내정보 갱신
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF67CA98),
        unselectedItemColor: Colors.grey[300],
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: '모의투자'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '챗봇'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: '순위'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
        ],
      ),
    );
  }
}
