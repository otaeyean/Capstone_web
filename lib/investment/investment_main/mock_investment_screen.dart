import 'package:flutter/material.dart';
import 'stock_buy.dart';
import 'stock_sell.dart';
import 'stock_history_list.dart';
import '../investment_main/reservation/reservation_history_list.dart'; 

class MockInvestmentScreen extends StatefulWidget {
  final String stockCode;

  MockInvestmentScreen({required this.stockCode});

  @override
  _MockInvestmentScreenState createState() => _MockInvestmentScreenState();
}

class _MockInvestmentScreenState extends State<MockInvestmentScreen> {
  int _selectedTabIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _onTabSelected(0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    child: Text(
                      '매수',
                      style: TextStyle(
                        color: _selectedTabIndex == 0 ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _onTabSelected(1),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    child: Text(
                      '매도',
                      style: TextStyle(
                        color: _selectedTabIndex == 1 ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _onTabSelected(2),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    child: Text(
                      '주문 내역',
                      style: TextStyle(
                        color: _selectedTabIndex == 2 ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _onTabSelected(3),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    child: Text(
                      '예약 내역',
                      style: TextStyle(
                        color: _selectedTabIndex == 3 ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _selectedTabIndex == 0
                  ? MockBuyScreen(stockCode: widget.stockCode)
                  : _selectedTabIndex == 1
                      ? MockSellScreen(stockCode: widget.stockCode)
                      : _selectedTabIndex == 2
                          ? OrderHistoryScreen(stockCode: widget.stockCode)
                          : ReservationHistoryScreen(stockCode: widget.stockCode), 
            ),
          ],
        ),
      ),
    );
  }
}
