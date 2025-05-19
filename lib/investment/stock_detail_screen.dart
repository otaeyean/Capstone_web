import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockapp/investment/detail_widgets/realtimetrade.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import './detail_widgets/stock_change_info.dart';
import 'chart/chart_main.dart';
import './news/news.dart';
import './investment_main/mock_investment_screen.dart';
import './detail_widgets/description.dart';
import 'package:stockapp/server/investment/info/stock_description_server.dart';
import 'package:stockapp/investment/detail_widgets/stock_info.dart';
import 'package:stockapp/investment/detail_widgets/info.dart';
import 'package:http/http.dart' as http;

class StockDetailScreen extends StatefulWidget {
  final Map<String, dynamic> stock;
  StockDetailScreen({required this.stock});

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  bool isLoading = true;
  String? companyDescription;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFavoriteStatus();
    _fetchCompanyDescription();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCompanyDescription() async {
    try {
      String response = await fetchCompanyDescription(widget.stock['stockName']);
      setState(() {
        companyDescription = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        companyDescription = '회사 소개를 불러오는 데 실패했습니다.';
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    final stockCode = widget.stock['stockCode'];
    setState(() => isFavorite = !isFavorite);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(stockCode, isFavorite);

    try {
      final url = Uri.parse('http://withyou.me:8080/watchlist/${isFavorite ? 'add' : 'remove'}');
      await http.post(url, headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': userId, 'stockCode': stockCode}));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isFavorite ? '관심 등록 완료' : '관심 삭제 완료'),
      ));
    } catch (_) {
      setState(() => isFavorite = !isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('에러 발생')));
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final stockCode = widget.stock['stockCode'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? savedFavorite = prefs.getBool(stockCode);
    if (savedFavorite != null) setState(() => isFavorite = savedFavorite);
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final stock = {
      'name': widget.stock['stockName'] ?? '이름 없음',
      'price': widget.stock['currentPrice'].toString(),
      'rise_percent': _parseDouble(widget.stock['changeRate']),
      'fall_percent': _parseDouble(widget.stock['changeRate']),
      'quantity': widget.stock['tradeVolume'] ?? 0,
      'stockCode': widget.stock['stockCode'] ?? '',
    };
    final stockCode = stock['stockCode'];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // ✅ Scaffold 기본 여백 제거를 위해 resizeToAvoidBottomInset false
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(stock['name'], style: TextStyle(color: Colors.black, fontSize: 16)),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.yellow : Colors.grey,
                size: 20,
              ),
              onPressed: _toggleFavorite,
            ),
            Icon(Icons.notifications_none, color: Colors.grey, size: 20),
          ],
        ),
        body: Column(
          children: [
            // ✅ 상단 현재가 정보와 변화율 (좌측 정렬)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  StockInfo(stock: stock),
                  SizedBox(width: 10),
                  StockChangeInfo(stock: stock), // 왼쪽 정렬
                ],
              ),
            ),
            // ✅ Tab 메뉴
            Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  Tab(child: Text('차트', style: TextStyle(fontSize: 13))),
                  Tab(child: Text('뉴스', style: TextStyle(fontSize: 13))),
                  Tab(child: Text('회사정보', style: TextStyle(fontSize: 13))),
                ],
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.green,
              ),
            ),
            // ✅ 본문
            Expanded(
              child: Row(
                children: [
                  // ✅ 왼쪽 콘텐츠
                  Expanded(
                    flex: 6, // ✅ 더 넓게 차지하도록 설정
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // ✅ 차트 + 실시간 체결
                        Column(
                          children: [
                            // ✅ 캔들차트 높이 확대
                            Expanded(
                              flex: 6,
                              child: StockChartMain(stockCode: stockCode),
                            ),
                            // ✅ 실시간 체결 그래프 높이 확대
                            Expanded(
                              flex: 4,
                              child: RealTimePriceChart(stockCode: stockCode),
                            ),
                          ],
                        ),
                        // ✅ 뉴스 탭
                        NewsScreen(stockName: stock['name']),
                        // ✅ 회사정보 탭
                        SingleChildScrollView(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('회사 정보', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              SizedBox(height: 6),
                              isLoading
                                  ? CircularProgressIndicator(strokeWidth: 1.5)
                                  : companyDescription != null
                                      ? StockDescription(stock: stock, description: companyDescription!)
                                      : Text('정보 없음'),
                              if (stockCode.isNotEmpty) StockInfoDetail(stockCode: stockCode),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✅ 오른쪽 주문창
                  Expanded(
                    flex: 4, // ✅ 오른쪽도 최대한 채우도록 조정
                    child: Container(
                      color: Colors.grey[100],
                      child: MockInvestmentScreen(stockCode: stockCode),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
