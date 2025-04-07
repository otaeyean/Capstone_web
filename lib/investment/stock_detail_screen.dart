import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import './detail_widgets/stock_change_info.dart';
import 'chart/chart_main.dart';
import './news/news.dart';
import './investment_main/mock_investment_screen.dart';
import './detail_widgets/description.dart';
import 'package:stockapp/server/investment/stock_description_server.dart'; 
import 'package:stockapp/investment/detail_widgets/stock_info.dart'; 
import 'package:stockapp/investment/detail_widgets/info.dart';
import 'package:http/http.dart' as http; 

class StockDetailScreen extends StatefulWidget {
  final Map<String, dynamic> stock;

  StockDetailScreen({required this.stock});

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  bool isFavorite = false;
  bool isLoading = true;
  String? companyDescription;

  @override
  void initState() {
    super.initState();
    _fetchCompanyDescription();
  }

  Future<void> _fetchCompanyDescription() async {
    if (widget.stock['stockName'] == null || widget.stock['stockName'] ==  'N/A') {
      setState(() {
        companyDescription = '주식 이름이 없습니다.';
        isLoading = false;
      });
      return;
    }

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

  // 관심 추가/삭제 API 호출
// 관심 상태 토글 함수
Future<void> _toggleFavorite() async {
  final userId = await AuthService.getUserId(); // 로그인된 사용자 ID 가져오기
  if (userId == null) {
    final snackBar = SnackBar(content: Text('로그인이 필요합니다.'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return;
  }

  final stockCode = widget.stock['stockCode'];

  setState(() {
    isFavorite = !isFavorite;
  });

  // 로컬 저장소에 관심 상태 저장
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(stockCode, isFavorite);  // 관심 상태 저장

  try {
    final url = Uri.parse('http://withyou.me:8080/watchlist/${isFavorite ? 'add' : 'remove'}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: '{"userId": "$userId", "stockCode": "$stockCode"}',
    );

    if (response.statusCode == 200) {
      final snackBar = SnackBar(
        content: Text(isFavorite ? '관심 항목으로 등록되었습니다' : '관심 항목에서 삭제되었습니다'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final errorMessage = 'API 요청 실패: ${response.statusCode}';
      final snackBar = SnackBar(content: Text(errorMessage));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  } catch (e) {
    setState(() {
      isFavorite = !isFavorite; // API 실패 시 상태 되돌리기
    });
    final snackBar = SnackBar(content: Text('관심 항목 추가/삭제에 실패했습니다.'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    print('에러 발생: $e');
  }
}

// 앱 로딩 시 관심 상태 불러오기
Future<void> _loadFavoriteStatus() async {
  final stockCode = widget.stock['stockCode'];

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? savedFavorite = prefs.getBool(stockCode);  // 로컬 저장소에서 관심 상태 불러오기

  if (savedFavorite != null) {
    setState(() {
      isFavorite = savedFavorite;  // 저장된 상태를 UI에 반영
    });
  }
}



  // ✅ 안전한 문자열 -> double 변환 함수
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final stock = {
      'name': widget.stock['stockName'] ?? '이름 없음',
      'price': widget.stock['currentPrice'].toString(),
      'rise_percent': _parseDouble(widget.stock['changeRate']), 
      'fall_percent': _parseDouble(widget.stock['changeRate']), 
      'quantity': widget.stock['tradeVolume'] ?? 0,
      'stockCode': widget.stock['stockCode'] ?? '',
    };

    final String stockName = stock['name'];
    final String stockCode = widget.stock['stockCode'] ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    StockInfo(stock: stock),
                    StockChangeInfo(stock: stock), // ✅ StockInfo 제거
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.yellow : Colors.grey,
                      ),
                      onPressed: _toggleFavorite, // 관심 추가/삭제 함수 호출
                    ),
                    Icon(
                      Icons.notifications_none,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  TabBar(
                  tabs: [
                    Tab(text: '차트'),
                    Tab(text: '모의 투자'),
                    Tab(text: '뉴스'),
                    Tab(text: '상세 정보'),
                  ],
                  labelColor: Colors.green, // 선택된 탭 텍스트 색상
                  unselectedLabelColor: Colors.black, // 선택되지 않은 탭 텍스트 색상
                  indicatorColor: Colors.green, // 선택된 탭 아래 선 색상
                ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        // 차트의 크기 동적으로 설정
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double chartHeight = constraints.maxHeight * 0.5; // 화면 높이에 비례하여 차트 크기 설정
                            return SizedBox(
                              height: chartHeight,
                              child: StockChartMain(stockCode: widget.stock['stockCode']), 
                            );
                          },
                        ),
                        MockInvestmentScreen(stockCode: stockCode), 
                        NewsScreen(stockName: stockName),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : companyDescription != null
                                      ? StockDescription(stock: stock, description: companyDescription!)
                                      : Text('회사 소개 정보를 불러올 수 없습니다.', style: TextStyle(color: Colors.red)),
                              if (stockCode.isNotEmpty) StockInfoDetail(stockCode: stockCode), 
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}