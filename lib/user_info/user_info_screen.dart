import 'package:flutter/material.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/server/userInfo/stock_service.dart';
import 'package:stockapp/data/user_stock_model.dart';
import 'package:stockapp/user_info/mystock_list.dart';
import 'package:stockapp/user_info/portfolio_summary.dart';
import 'package:stockapp/user_info/sort_dropdown.dart';
import 'package:stockapp/user_info/user_profile.dart';
import 'achievement_rate_widget.dart';
class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  UserInfoScreenState createState() => UserInfoScreenState();
}

class UserInfoScreenState extends State<UserInfoScreen> {
  List<UserStockModel> _userStocks = [];
  String userId = '';

  void refreshStock() {
    if (userId.isNotEmpty) {
      _loadStockData();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _loadUserId() async {
    String? savedUserId = await AuthService.getUserId();
    if (savedUserId == null || savedUserId.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        userId = savedUserId;
      });
      _loadStockData();
    }
  }

  void _loadStockData() async {
    try {
      List<UserStockModel> stocks = await StockService.fetchStockList(userId);
      setState(() {
        _userStocks = stocks;
      });
    } catch (e) {
      print("Error loading stock data: $e");
    }
  }

  void _onSortChanged(List<UserStockModel> sortedStocks) {
    setState(() {
      _userStocks = sortedStocks;
    });
  }
@override
Widget build(BuildContext context) {
  return userId.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : Scaffold(
          backgroundColor: const Color.fromARGB(255, 244, 248, 244),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 130), // ⬅️ 전체 위 여백
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // ⬅️ 가운데 정렬
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 왼쪽 영역
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  UserProfile(userId: userId),
                                  const Spacer(),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    CombinedBalanceSummary(userId: userId),
                                    const SizedBox(height: 16),
                                    AchievementRateWidget(userId: userId),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 중앙 구분선
                      Container(
                        width: 1,
                        color: Colors.grey.shade300,
                        margin: const EdgeInsets.symmetric(vertical: 40),
                      ),

                      // 오른쪽 영역
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "내 종목 목록",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  SortDropdown(
                                    stocks: _userStocks,
                                    onSortChanged: _onSortChanged,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              MyStockList(stocks: _userStocks),
                            ],
                          ),
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
