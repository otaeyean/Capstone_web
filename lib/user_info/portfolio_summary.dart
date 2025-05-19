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

  bool _isSaving = false;
  String? _inputError;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(Duration(seconds: 10), (_) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
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
        _controller.text = balance.toStringAsFixed(0);
        _inputError = null;
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

  Future<void> _updateBalance() async {
    setState(() {
      _inputError = null;
    });

    double? newBalance = double.tryParse(_controller.text);
    if (newBalance == null || newBalance < 0) {
      setState(() {
        _inputError = "유효한 금액을 입력하세요.";
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    bool success = await UserBalanceService().updateBalance(widget.userId, newBalance);
    if (success) {
      setState(() {
        balance = newBalance;
        _inputError = null;
      });
    } else {
      setState(() {
        _inputError = "금액 업데이트에 실패했습니다.";
      });
    }

    setState(() {
      _isSaving = false;
    });
  }

  Future<void> _resetBalance() async {
    setState(() {
      _isSaving = true;
      _inputError = null;
    });

    bool success = await UserBalanceService().resetBalance(widget.userId);
    if (success) {
      setState(() {
        balance = 0;
        _controller.text = '0';
      });
    } else {
      setState(() {
        _inputError = "초기화에 실패했습니다.";
      });
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 50, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "보유 금액 설정",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "금액 입력",
              hintText: "금액을 입력하세요",
              errorText: _inputError,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
            style: TextStyle(fontSize: 18),
            enabled: !_isSaving,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _updateBalance,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('저장', style: TextStyle(fontSize: 16, color: Colors.blue)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _resetBalance,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('초기화', style: TextStyle(fontSize: 16, color: Colors.red)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade900,
              borderRadius: BorderRadius.circular(20),
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
                Text("현재 보유 금액", style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 6),
                Text("${formatter.format(balance)} 원",
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(errorMessage, style: TextStyle(color: Colors.redAccent)),
                  ),
                const SizedBox(height: 20),
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

}
