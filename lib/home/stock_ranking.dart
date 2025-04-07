import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stockapp/stock_api_service.dart';
import '../investment/stock_detail_screen.dart';

class StockRanking extends StatefulWidget {
  @override
  _StockRankingState createState() => _StockRankingState();
}

class _StockRankingState extends State<StockRanking> {
  String selectedMarket = "국내";
  List<String> categories = ["상승률", "하락률", "거래량"];
  int categoryIndex = 0;
  List<Map<String, dynamic>> stockData = [];
  List<Map<String, dynamic>> visibleRankings = [];
  bool isLoading = true;
  bool isError = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadStockData();
    _startAutoSwitch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStockData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      isError = false;
    });

    List<Map<String, dynamic>> stocks = [];
    String selectedCategory = categories[categoryIndex];

    try {
      String endpoint = "";
      if (selectedMarket == "국내") {
        if (selectedCategory == "상승률") {
          endpoint = "rise";
        } else if (selectedCategory == "하락률") {
          endpoint = "fall";
        } else if (selectedCategory == "거래량") {
          endpoint = "trade-volume";
        }
      } else {
        if (selectedCategory == "상승률") {
          endpoint = "rise/overseas";
        } else if (selectedCategory == "하락률") {
          endpoint = "fall/overseas";
        } else if (selectedCategory == "거래량") {
          endpoint = "trade-volume/overseas";
        }
      }

      stocks = await fetchStockData(endpoint);
      if (stocks.isEmpty) throw Exception("데이터 없음");

      if (mounted) {
        setState(() {
          stockData = stocks;
          visibleRankings = stockData.sublist(0, 5);
          isLoading = false;
        });
      }
    } catch (e) {
      print("에러 발생: $e");
      if (mounted) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    }
  }

  void _startAutoSwitch() {
    _timer = Timer.periodic(Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        categoryIndex = (categoryIndex + 1) % categories.length;
      });
      _loadStockData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMarketButton("국내"),
            SizedBox(width: 16),
            _buildMarketButton("해외"),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: categories.map((c) => _buildCategoryButton(c)).toList(),
        ),
        SizedBox(height: 10),
        if (isLoading)
          Center(child: CircularProgressIndicator())
        else if (isError)
          Center(
            child: Text(
              "데이터를 불러올 수 없습니다.",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          )
        else
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 800), // 부드럽게 0.8초 동안
              transitionBuilder: (child, animation) {
                // 애니메이션을 Fade로 처리
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildStockList(),
            ),
          ),
      ],
    );
  }

  Widget _buildMarketButton(String market) {
    bool isSelected = selectedMarket == market;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMarket = market;
          categoryIndex = 0;
          _loadStockData();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF03314B ) : Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Color(0xFF03314B )),
        ),
        child: Text(
          market,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF03314B ),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    bool isSelected = categories[categoryIndex] == category;
    Color iconColor = isSelected
        ? (category == "상승률"
            ? Colors.red
            : category == "하락률"
                ? Colors.blue
                : Colors.orange)
        : Colors.grey;

    IconData iconData = category == "상승률"
        ? Icons.trending_up
        : category == "하락률"
            ? Icons.trending_down
            : Icons.autorenew;

    return Column(
      children: [
        Icon(iconData, color: iconColor, size: 20),
        Text(
          category,
          style: TextStyle(
            color: iconColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStockList() {
    return Column(
      key: ValueKey(categoryIndex),
      children: visibleRankings.map((stock) {
        int rank = stockData.indexOf(stock) + 1;
        double changeRate = stock['changeRate'];
        bool isRising = changeRate >= 0;
        Color textColor = isRising ? Colors.red : Colors.blue;
        String arrow = isRising ? '▲' : '▼';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StockDetailScreen(stock: stock),
              ),
            );
          },
          child: Card(
            color: Colors.white,
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$rank. ${stock['stockName']}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${stock['currentPrice']} 원",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      Text(
                        "$arrow ${changeRate.toStringAsFixed(2)}%",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
