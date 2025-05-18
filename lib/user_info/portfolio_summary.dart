import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/server/userInfo/portfolio_server.dart';
import 'package:stockapp/server/userInfo/user_balance_server.dart';

class CombinedBalanceSummary extends StatefulWidget {
  final String userId;

  const CombinedBalanceSummary({required this.userId});

  @override
  State<CombinedBalanceSummary> createState() => _CombinedBalanceSummaryState();
}

class _CombinedBalanceSummaryState extends State<CombinedBalanceSummary> {
  double balance = 0;
  String totalPurchase = "0 원";
  String totalEvaluation = "0 원";
  String totalProfit = "0 원";
  String totalProfitRate = "0 %";
  String errorMessage = '';
  Timer? _timer;

  final NumberFormat formatter = NumberFormat('#,###');
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(Duration(seconds: 10), (_) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final data = await PortfolioService.fetchPortfolioData(widget.userId);
      setState(() {
        balance = data['balance'].toDouble();
        totalPurchase = "${_formatInt(data['totalPurchase'])} 원";
        totalEvaluation = "${_formatInt(data['totalEvaluation'])} 원";
        totalProfit = "${_formatInt(data['totalProfit'])} 원";
        totalProfitRate = _formatProfitRate(data['totalProfitRate']);
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = '데이터를 불러오는 중 오류가 발생했습니다.';
      });
    }
  }

  String _formatInt(dynamic value) {
    if (value is double) {
      return formatter.format(value.toInt());
    } else if (value is int) {
      return formatter.format(value);
    }
    return "0";
  }

  String _formatProfitRate(dynamic value) {
    if (value is double) {
      return "${value.toStringAsFixed(2)} %";
    } else if (value is int) {
      return "$value %";
    }
    return "0 %";
  }

  void _updateBalance() async {
    double? newBalance = double.tryParse(_controller.text);
    if (newBalance != null) {
      bool success = await UserBalanceService().updateBalance(widget.userId, newBalance);
      if (success) {
        setState(() {
          balance = newBalance;
        });
      }
    }
  }

  void _resetBalance() async {
    bool success = await UserBalanceService().resetBalance(widget.userId);
    if (success) {
      setState(() {
        balance = 0;
      });
    }
  }

  void _showBalanceInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("금액 입력", style: TextStyle(color: Colors.black)),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "금액을 입력하세요",
              hintStyle: TextStyle(color: Colors.black45),
            ),
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                _updateBalance();
                Navigator.pop(context);
              },
              child: Text("확인", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _confirmResetBalance(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("금액 초기화", style: TextStyle(color: Colors.black)),
          content: Text("설정해놓으신 금액이 초기화됩니다. 진행하시겠습니까?", style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                _resetBalance();
                Navigator.pop(context);
              },
              child: Text("확인", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF001F3F), Color(0xFF003366)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("보유 금액", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 6),
                  Text("${formatter.format(balance)} 원", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  _iconButton(FontAwesomeIcons.gear, "금액설정", Color(0xFF64C38C), () => _showBalanceInputDialog(context), true),
                  SizedBox(width: 10),
                  _iconButton(FontAwesomeIcons.arrowRotateLeft, "초기화", Colors.redAccent, () => _confirmResetBalance(context)),
                ],
              )
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoColumn(FontAwesomeIcons.cartShopping, "총매입", totalPurchase),
              _buildInfoColumn(FontAwesomeIcons.chartLine, "총평가", totalEvaluation),
              _buildInfoColumn(FontAwesomeIcons.coins, "총손익", totalProfit),
              _buildInfoColumn(FontAwesomeIcons.percent, "수익률", totalProfitRate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: FaIcon(icon, color: Colors.white, size: 20),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        )
      ],
    );
  }

  Widget _iconButton(IconData icon, String label, Color color, VoidCallback onTap, [bool greenStyle = false]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: greenStyle ? Color(0xFF64C38C).withOpacity(0.15) : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: greenStyle ? Border.all(color: Color(0xFF64C38C).withOpacity(0.5)) : null,
        ),
        child: Row(
          children: [
            FaIcon(icon, color: color, size: 14),
            SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
