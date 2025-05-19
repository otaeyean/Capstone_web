import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stockapp/stock_api_service.dart';
import '../investment/stock_detail_screen.dart';

class StockRanking extends StatefulWidget {
  @override
  _StockRankingState createState() => _StockRankingState();
}

class _StockRankingState extends State<StockRanking> {
  List<Map<String, dynamic>> domesticRisingStocks = [];
  List<Map<String, dynamic>> domesticFallingStocks = [];
  List<Map<String, dynamic>> overseasRisingStocks = [];
  List<Map<String, dynamic>> overseasFallingStocks = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _loadAllStockData();
  }

  Future<void> _loadAllStockData() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      // 국내 상승, 하락
      List<Map<String, dynamic>> domesticRise = await fetchStockData("rise");
      List<Map<String, dynamic>> domesticFall = await fetchStockData("fall");

      // 해외 상승, 하락
      List<Map<String, dynamic>> overseasRise = await fetchStockData("rise/overseas");
      List<Map<String, dynamic>> overseasFall = await fetchStockData("fall/overseas");

      setState(() {
        domesticRisingStocks = domesticRise.take(5).toList();
        domesticFallingStocks = domesticFall.take(5).toList();
        overseasRisingStocks = overseasRise.take(5).toList();
        overseasFallingStocks = overseasFall.take(5).toList();
        isLoading = false;
      });
    } catch (e) {
      print("에러: $e");
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.flash_on, color: const Color.fromARGB(255, 15, 30, 70), size: 24),
                SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MinSans',
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(text: "주식 "),
                      TextSpan(
                        text: "랭킹",
                        style: TextStyle(color: Colors.green),
                      ),
                      TextSpan(text: " 확인"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          if (isLoading)
            Center(child: CircularProgressIndicator(color: Color(0xFF03314B)))
          else if (isError)
            Center(
              child: Text(
                "데이터를 불러올 수 없습니다.",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "국내 상승/하락 주식",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF03314B),
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDualColumnList(domesticRisingStocks, domesticFallingStocks, false),

                    SizedBox(height: 30),

                    Text(
                      "해외 상승/하락 주식",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF03314B),
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDualColumnList(overseasRisingStocks, overseasFallingStocks, true),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDualColumnList(List<Map<String, dynamic>> rising, List<Map<String, dynamic>> falling, bool isOverseas) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildStockList(rising, true, isOverseas)),
        SizedBox(width: 12),
        Expanded(child: _buildStockList(falling, false, isOverseas)),
      ],
    );
  }

  Widget _buildStockList(List<Map<String, dynamic>> stocks, bool isRising, bool isOverseas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRising ? "상승률" : "하락률",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isRising ? Colors.red : Colors.blue,
          ),
        ),
        SizedBox(height: 8),
        ...stocks.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> stock = entry.value;
          double changeRate = stock['changeRate'];
          Color textColor = isRising ? Colors.red : Colors.blue;

          String trimmedName = stock['stockName'].length > 20
              ? stock['stockName'].substring(0, 18) + '...'
              : stock['stockName'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StockDetailScreen(stock: stock),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 6),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 왼쪽: 이름 + 가격
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trimmedName,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontFamily: 'MinSans',
                            fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        isOverseas
                            ? "\$${stock['currentPrice']}"
                            : "${stock['currentPrice']} 원",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  // 오른쪽: 상승/하락률
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isRising
                              ? const Color.fromARGB(255, 254, 235, 237)
                              : const Color.fromARGB(255, 229, 241, 252),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${changeRate.toStringAsFixed(2)}%",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
