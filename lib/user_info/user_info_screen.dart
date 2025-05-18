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
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            // ✅ AppBar 추가 (투명 배경, 뒤로가기 버튼)
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            extendBodyBehindAppBar: true,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // ✅ 상단 배경 + 감성 효과
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 250,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF64C38C),
                              Color(0xFF3CB98E),
                              Color(0xFF1E8C74),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(24),
                          ),
                        ),
                      ),
                      Positioned(top: 40, left: 30, child: _circleDot(20, Colors.white.withOpacity(0.2))),
                      Positioned(top: 80, right: 40, child: _circleDot(14, Colors.white.withOpacity(0.15))),
                      Positioned(bottom: 40, right: 60, child: _circleDot(26, Colors.white.withOpacity(0.1))),
                      Positioned(bottom: 60, left: 50, child: _circleDot(10, Colors.white.withOpacity(0.25))),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, top: 90), // AppBar 공간 고려해 90으로 조정
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: UserProfile(userId: userId),
                        ),
                      ),
                    ],
                  ),

              Transform.translate(
                offset: const Offset(0, -30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      CombinedBalanceSummary(userId: userId),
                      const SizedBox(height: 16),
                      AchievementRateWidget(userId: userId), // 여기에 AchievementRateWidget을 사용
                    ],
                  ),
                ),
              ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        SortDropdown(
                          stocks: _userStocks,
                          onSortChanged: _onSortChanged,
                        ),
                        const SizedBox(height: 10),
                        MyStockList(stocks: _userStocks),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _circleDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
