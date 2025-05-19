import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stockapp/home/searchable_stock_list.dart';
import 'package:stockapp/investment/sortable_header.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/stock_api_service.dart';
import 'package:stockapp/investment/stock_list.dart';
import './recommended_list.dart'; // 추가된 추천 탭 import
import 'stock_detail_screen.dart';

class InvestmentScreen extends StatefulWidget {
  @override
  _InvestmentScreenState createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  List<Map<String, dynamic>> stocks = [];
  List<Map<String, dynamic>> allStocks = [];
  List<Map<String, dynamic>> watchlistStocks = [];
  bool isLoading = true;
  bool isSearchLoading = false;
  String selectedSort = "상승률순";
  String selectedCategory = "전체";
  List<Map<String, dynamic>> searchStockList = [];

  @override
  void initState() {
    super.initState();
    _loadStockData();
    _loadSearchStockData();
  }

  Future<void> _loadStockData() async {
    setState(() => isLoading = true);
    try {
      final userId = await AuthService.getUserId();
      List<Map<String, dynamic>> stockData = [];
      List<Map<String, dynamic>> overseasData = [];
      List<Map<String, dynamic>> watchlistData = [];

      if (selectedSort == "상승률순") {
        stockData = await fetchStockData("rise");
        overseasData = await fetchStockData("rise/overseas", period: "DAILY");
      } else if (selectedSort == "하락률순") {
        stockData = await fetchStockData("fall");
        overseasData = await fetchStockData("fall/overseas", period: "DAILY");
      } else if (selectedSort == "거래량순") {
        stockData = await fetchStockData("trade-volume");
        overseasData = await fetchStockData("trade-volume/overseas");
      }

      if (userId != null) {
        watchlistData = await fetchWatchlistData(userId);
      }

      setState(() {
        allStocks = [...stockData, ...overseasData];
        watchlistStocks = watchlistData;
        _filterStocksByCategory(selectedCategory);
        isLoading = false;
      });
    } catch (e) {
      print("데이터 로딩 실패: $e");
      setState(() => isLoading = false);
    }
  }

Future<List<Map<String, dynamic>>> fetchWatchlistData(String userId) async {
  final url = Uri.parse('http://withyou.me:8080/watchlist/$userId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
    return data.map((item) {
      final changePercent = _toDouble(item["stockChangePercent"]);
      final isRise = changePercent >= 0;
      return {
        "stockCode": item["stockCode"] ?? "",
        "stockName": item["stockName"] ?? "이름 없음",
        "stockCurrentPrice": _toDouble(item["stockCurrentPrice"]),
        "stockChange": _toDouble(item["stockChange"]),
        "stockChangePercent": changePercent,
        "acml_vol": _toInt(item["acml_vol"]),
        "acml_tr_pbmn": _toDouble(item["acml_tr_pbmn"]),

        // 👇 상세 화면에서 요구되는 필드 추가
        "price": _toDouble(item["stockCurrentPrice"]),
        "change_value": _toDouble(item["stockChange"]),
        "rise_percent": isRise ? changePercent : 0.0,
        "fall_percent": !isRise ? changePercent : 0.0,
      };
    }).toList();
  } else {
    return [];
  }
}

  Future<void> _loadSearchStockData() async {
    setState(() => isSearchLoading = true);
    try {
      final response = await http.get(Uri.parse('http://withyou.me:8080/stock-list'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          searchStockList = data.map((item) => {
                'stockCode': item['stockCode'],
                'stockName': item['stockName'],
              }).toList();
          isSearchLoading = false;
        });
      } else {
        throw Exception('주식 리스트를 가져오는 데 실패했습니다.');
      }
    } catch (e) {
      setState(() => isSearchLoading = false);
    }
  }

  void _filterStocksByCategory(String category) async {
  setState(() {
    selectedCategory = category;
    isLoading = true;
  });

  if (category == "관심") {
    try {
      final userId = await AuthService.getUserId();
      if (userId != null) {
        final updatedWatchlist = await fetchWatchlistData(userId);

        setState(() {
          watchlistStocks = updatedWatchlist;
          stocks = watchlistStocks;
          _sortStocks(); // 정렬 유지!
          isLoading = false;
        });
      } else {
        setState(() {
          stocks = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("관심목록 갱신 실패: $e");
      setState(() {
        stocks = [];
        isLoading = false;
      });
    }
  } else {
    setState(() {
      stocks = category == "전체"
          ? allStocks
          : category == "국내"
              ? allStocks.where((stock) => !stock.containsKey("excd")).toList()
              : allStocks.where((stock) => stock.containsKey("excd")).toList();
      _sortStocks(); // 정렬 유지!
      isLoading = false;
    });
  }
}


  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }

  void _sortStocks() {
    setState(() {
      if (selectedCategory == "관심") {
        if (selectedSort == "상승률순") {
          stocks.sort((a, b) => _toDouble(b['stockChangePercent']).compareTo(_toDouble(a['stockChangePercent'])));
        } else if (selectedSort == "하락률순") {
          stocks.sort((a, b) => _toDouble(a['stockChangePercent']).compareTo(_toDouble(b['stockChangePercent'])));
        } else if (selectedSort == "거래량순") {
          stocks.sort((a, b) => _toInt(b['acml_vol']).compareTo(_toInt(a['acml_vol'])));
        }
      }
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption("상승률순"),
              _buildSortOption("하락률순"),
              _buildSortOption("거래량순")
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String option) {
    return ListTile(
      title: Text(option,
          style: TextStyle(
              fontSize: 14,
              fontWeight: selectedSort == option ? FontWeight.bold : FontWeight.normal,
              color: selectedSort == option ? Color(0xFF67CA98) : Colors.black)),
      trailing: selectedSort == option ? Icon(Icons.check, color: Color(0xFF67CA98)) : null,
      onTap: () {
        Navigator.pop(context);
        setState(() {
          selectedSort = option;
          _loadStockData();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6F9),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                     
                        SizedBox(height: 16),
                        isSearchLoading
                            ? Center(child: CircularProgressIndicator())
                            : SearchableStockList(stockList: searchStockList),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: ["전체", "국내", "해외", "관심", "추천"].map((category) {
                                bool isSelected = selectedCategory == category;
                                return GestureDetector(
                                  onTap: () {
                                    if (category == "추천") {
                                      setState(() => selectedCategory = "추천");
                                    } else {
                                      _filterStocksByCategory(category);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    margin: EdgeInsets.only(right: 8),
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Color(0xFF67CA98).withOpacity(0.2) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Color(0xFF67CA98) : Colors.grey,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            if (selectedCategory != "추천")
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFF67CA98),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                                onPressed: _showSortOptions,
                                icon: Icon(Icons.sort, size: 16, color: Colors.white),
                                label: Text(selectedSort, style: TextStyle(color: Colors.white, fontSize: 14)),
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (selectedCategory != "추천") StockSortHeader(),
                  Expanded(
                    child: selectedCategory == "추천"
                        ? RecommendationTab()
                        : stocks.isEmpty
                            ? Center(child: Text("데이터 없음", style: TextStyle(fontSize: 18, color: Colors.grey)))
                            : StockList(
                                stocks: List<Map<String, dynamic>>.from(stocks),
                                isTradeVolumeSelected: selectedSort == "거래량순",
                              ),
                  ),
                ],
              ),
      ),
    );
  }
}
