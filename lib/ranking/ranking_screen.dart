import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../server/SharedPreferences/user_nickname.dart';
import '../server/userInfo/portfolio_server.dart';
import '../data/user_stock_model.dart';
import '../server/userInfo/stock_service.dart';
import './ranking_tile.dart';

class RankingScreen extends StatefulWidget {
  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<dynamic> rankings = [];
  List<UserStockModel> userStocks = [];
  bool isLoading = true;
  String? userId;
  double? totalProfit;
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    initializeData();

    // 2초마다 데이터 갱신
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      initializeData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // 타이머 종료
    super.dispose();
  }

  Future<void> initializeData() async {
    final id = await AuthService.getUserId();
    if (id != null) {
      final portfolioData = await PortfolioService.fetchPortfolioData(id);
      final stocks = await StockService.fetchStockList(id);

      setState(() {
        userId = id;
        totalProfit = portfolioData['totalProfit']?.toDouble();
        userStocks = stocks;
      });
    }
    await fetchRankings();
  }

  Future<void> fetchRankings() async {
    final response = await http.get(Uri.parse('http://withyou.me:8080/user-info/user-profits'));
    if (response.statusCode == 200) {
      setState(() {
        rankings = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
List<BarChartGroupData> _buildBarChartData() {
  return userStocks.asMap().entries.map((entry) {
    int index = entry.key;
    UserStockModel stock = entry.value;

    // 양/음에 따라 색상만 다르게
    Color startColor = stock.profitRate < 0 ? Colors.blue.shade200 : Colors.green.shade400;
    Color endColor = stock.profitRate < 0 ? Colors.blue.shade100 : Colors.green.shade200;

    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: stock.profitRate.abs(), // 👈 항상 위로 그리기
          width: 45,
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ],
    );
  }).toList();
}


  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 42,
       getTitlesWidget: (value, meta) {
  int index = value.toInt();
  if (index >= 0 && index < userStocks.length) {
    final stock = userStocks[index];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 바 위에 수익률 텍스트 (선택사항)
        Text(
          '${stock.profitRate.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 14,
            color: stock.profitRate >= 0 ? Colors.green : Colors.blue,
          ),
        ),
        SizedBox(height: 4),
        // 기업 이름은 항상 아래
        Text(
          stock.name.length > 6 ? stock.name.substring(0, 6) : stock.name,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
  return Text('');
},
        ),
      ),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFDDF6E3),
            Color(0xFFCCE5FB),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // 이 부분이 중요!!
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 120),
                                    Text(
                                      '현재 $userId 님의 총 수입은',
                                      style: TextStyle(
                                        fontFamily: 'MinSans',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 28,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${totalProfit?.toStringAsFixed(0) ?? '-'}원 입니다',
                                      style: TextStyle(
                                        fontFamily: 'MinSans',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 35,
                                        color: totalProfit != null && totalProfit! > 0
                                            ? Colors.green
                                            : Colors.blue, // 수익금에 따라 색상 조정
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            if (userStocks.isNotEmpty)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Container(
                                    width: userStocks.length * 70,
                                    height: 250,
                                    padding: EdgeInsets.all(16),
                                    child: BarChart(
                                      BarChartData(
                                        borderData: FlBorderData(show: false),
                                        titlesData: _buildTitlesData(),
                                        gridData: FlGridData(show: false),
                                        barGroups: _buildBarChartData(),
                                        groupsSpace: 60,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: rankings.length,
                          itemBuilder: (context, index) {
                            final item = rankings[index];
                            return RankingTile(
                              rank: index + 1,
                              userId: item['userId'],
                              profit: item['totalProfit'],
                            );
                          },
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
