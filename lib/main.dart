import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockapp/ranking/ranking_screen.dart';
import 'home/home_screen.dart';
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
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  late final List<Widget> _pages = [
    HomeScreen(key: _homeKey),
    InvestmentScreen(),
    ChatbotScreen(),
    RankingScreen(),
    UserInfoScreen(key: _userInfoKey),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      _homeKey.currentState?.refreshUserStocks();
    } else if (index == 4) {
      _userInfoKey.currentState?.refreshStock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex], // 현재 선택된 화면

       
        ],
      ),
    );
  }
}
