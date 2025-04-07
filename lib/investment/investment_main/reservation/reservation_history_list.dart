import 'package:flutter/material.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/server/investment/reservation/reserve_history_server.dart';

class ReservationHistoryScreen extends StatefulWidget {
  final String stockCode;

  ReservationHistoryScreen({required this.stockCode});

  @override
  _ReserveHistoryScreenState createState() => _ReserveHistoryScreenState();
}

class _ReserveHistoryScreenState extends State<ReservationHistoryScreen> {
  List<dynamic> _reserveHistory = [];
  bool _isLoading = true;
  String? _userId;
  int _selectedTabIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    String? userId = await AuthService.getUserId();
    if (userId != null) {
      setState(() {
        _userId = userId;
      });
      _fetchReserveHistory(userId);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchReserveHistory(String userId) async {
    List<dynamic> history = await ReserveHistoryService.fetchReserveHistory(userId);
    setState(() {
      _reserveHistory = history;
      _isLoading = false;
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredReserves = _reserveHistory.where((order) {
      bool matchesStockCode = order["stockCode"] == widget.stockCode;
      if (_selectedTabIndex == 0) return matchesStockCode && order["transactionType"] == "BUY";
      if (_selectedTabIndex == 1) return matchesStockCode && order["transactionType"] == "SELL";
      return matchesStockCode;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildTabText(0, "매수", Colors.red),
                SizedBox(width: 16),
                _buildTabText(1, "매도", Colors.blue),
                SizedBox(width: 16),
                _buildTabText(2, "전체내역", Colors.black, underline: true),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : (_userId == null || _userId!.isEmpty)
                    ? Center(child: Text("사용자 정보가 없습니다. 로그인해주세요.", style: TextStyle(color: Colors.black)))
                    : filteredReserves.isEmpty
                        ? Center(child: Text("해당 종목의 예약 내역이 없습니다.", style: TextStyle(color: Colors.black)))
                        : ListView.builder(
                            itemCount: filteredReserves.length,
                            itemBuilder: (context, index) {
                              final order = filteredReserves[index];
                              bool isBuy = order["transactionType"] == "BUY";
                              Color textColor = isBuy ? Colors.red : Colors.blue;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isBuy ? "매수 예약" : "매도 예약",
                                          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          order['reserveDate'],
                                          style: TextStyle(color: Colors.grey, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("예약 가격", style: TextStyle(color: Colors.grey, fontSize: 14)),
                                        Text("${order['targetPrice']}", style: TextStyle(color: Colors.black, fontSize: 14)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("예약 수량", style: TextStyle(color: Colors.grey, fontSize: 14)),
                                        Text("${order['quantity']}", style: TextStyle(color: Colors.black, fontSize: 14)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("상태", style: TextStyle(color: Colors.grey, fontSize: 14)),
                                        Text("${order['transactionStatus']}", style: TextStyle(color: Colors.black, fontSize: 14)),
                                      ],
                                    ),
                                    Divider(color: Colors.grey),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabText(int index, String text, Color selectedColor, {bool underline = false}) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? selectedColor : Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          decoration: (isSelected && underline) ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }
}
