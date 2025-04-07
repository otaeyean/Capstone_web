import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // ✅ Provider 패키지 추가
import 'home/home_screen.dart';
import 'investment/investment_screen.dart';
import 'chatbot/chatbot_main_screen.dart';
import 'user_info/user_info_screen.dart';
import 'investment/chart/stock_provider.dart';  // ✅ StockProvider import

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StockProvider()),  // ✅ Provider 등록
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WithYou',
      theme: ThemeData(
        fontFamily: 'NotoSans',
        primarySwatch: Colors.blue,
        canvasColor: Colors.white ,
        scaffoldBackgroundColor: Colors.white, // 전체 배경을 흰색으로 설정
      ),
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
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

  // ✅ UserInfoScreen에 접근하기 위한 GlobalKey
  final GlobalKey<UserInfoScreenState> _userInfoKey = GlobalKey<UserInfoScreenState>();

  late final List<Widget> _pages = [
    HomeScreen(),
    InvestmentScreen(),
    ChatbotScreen(),
    UserInfoScreen(key: _userInfoKey), // ✅ Key 적용
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // ✅ "내 정보" 탭 클릭 시 강제로 데이터 리로드
    if (index == 3) {
      _userInfoKey.currentState?.refreshStock();
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
        selectedItemColor: Color(0xFF67CA98 ),
        unselectedItemColor: Colors.grey[300],
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: '모의투자'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '챗봇'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
        ],
      ),
    );
  }
}
