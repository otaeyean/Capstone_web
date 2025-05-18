import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockapp/server/investment/user_balance_server.dart';
import 'package:stockapp/server/investment/stock_sell_server.dart';
import 'package:stockapp/investment/investment_main/dialog/success_sell_dialog.dart'; 
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:http/http.dart' as http;
import './reservation/reservation_sell_settings.dart';
import 'dart:convert';

class MockSellScreen extends StatefulWidget {
  final String stockCode;

  MockSellScreen({required this.stockCode});

  @override
  _MockSellScreenState createState() => _MockSellScreenState();
}

class _MockSellScreenState extends State<MockSellScreen> {
  TextEditingController _quantityController = TextEditingController();
  final UserBalanceService _balanceService = UserBalanceService();
  double? _balance;
  double _price = 0;  
  String? userId;
  int? confirmedQuantity;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchStockPrice();  
  }

  Future<void> _loadUserId() async {
    String? id = await AuthService.getUserId();
    if (id != null) {
      setState(() {
        userId = id;
      });
      _loadBalance(id);
    }
  }

  Future<void> _loadBalance(String id) async {
    double? balance = await _balanceService.fetchBalance(id);
    if (balance != null) {
      setState(() {
        _balance = balance;
      });
    }
  }

  Future<void> _fetchStockPrice() async {
    final response = await http.get(Uri.parse('http://withyou.me:8080/current-price?stockCode=${widget.stockCode}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _price = data['stockPrice']?.toDouble() ?? 0;  
      });
    } else {
      setState(() {
        _errorMessage = "현재가를 가져오지 못했습니다."; 
      });
    }
  }

  Future<void> _sellStock() async {
    if (userId == null || confirmedQuantity == null) return;

    bool success = await StockServer.sellStock(userId!, widget.stockCode, confirmedQuantity!);
    if (success) {
      print("매도 성공");
      _loadBalance(userId!);
      setState(() {
        confirmedQuantity = null; 
      });
      _showSuccessDialog();
    } else {
      print("매도 실패");
    }
  }
void _showConfirmationDialog() {
  final isForeignStock = widget.stockCode.contains(RegExp(r'[A-Za-z]'));
  final formattedPrice = isForeignStock
      ? '\$${_price.toStringAsFixed(2)}'
      : '${_price.toStringAsFixed(0)}원';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text("매도 확인"),
            SizedBox(width: 8),
            Icon(Icons.help_outline, color: Colors.black),
          ],
        ),
        content: Text(
          "체결 가격: $formattedPrice\n매도 수량: $confirmedQuantity주\n\n진행하시겠습니까?",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("취소", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sellStock();
            },
            child: Text("확인", style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    },
  );
}


bool get _isForeignStock {
  return widget.stockCode.contains(RegExp(r'[A-Za-z]'));
}

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessSellDialog();
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); 
      }
    });
  }

  void _confirmQuantity() {
    int quantity = int.tryParse(_quantityController.text.replaceAll(RegExp(r'\D'), '')) ?? 0;
    if (quantity > 0) {
      setState(() {
        confirmedQuantity = quantity;
      });
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea( // (선택) 노치나 상태바 침범 방지
      child: SingleChildScrollView( // <- 스크롤 가능하게 변경
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceWidget(),
              SizedBox(height: 20),
              _buildPriceWidget(),
              SizedBox(height: 20),
              _buildQuantityWidget(),
              SizedBox(height: 16),
              Divider(color: Colors.grey, thickness: 1),
              BuyReservationSettingsScreen(
                currentPrice: _price ?? 0.0,
                stockCode: widget.stockCode,
              ),
              SizedBox(height: 30),
              _buildSellButton(), 
              if (_errorMessage != null) _buildErrorMessageWidget(),
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget _buildBalanceWidget() {
    return _balance != null
        ? Text(
            '보유 금액 ${_balance!.toStringAsFixed(0)}원',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(187, 0, 0, 0)),
          )
        : Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.grey[300]!,
            child: Container(width: 180, height: 24, color: Colors.white),
          );
  }
Widget _buildPriceWidget() {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('현재가', style: TextStyle(color: Colors.black, fontSize: 16)),
        SizedBox(height: 8),
        Text(
          _price != null
              ? _isForeignStock
                  ? '\$${_price!.toStringAsFixed(2)}'
                  : '${_price!.toStringAsFixed(0)}원'
              : _isForeignStock ? '\$0.00' : '0원',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}


    Widget _buildQuantityWidget() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('수량', style: TextStyle(color: Colors.black, fontSize: 16)),
          SizedBox(height: 8),
          TextField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
          hintText: '몇 주 매도할까요?',
          hintStyle: TextStyle(color: Colors.grey[400]),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          prefixIcon: Icon(Icons.shopping_cart_outlined, color: Colors.grey),
          suffixText: '주',
          suffixStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF22B379)),
          ),
        ),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        onChanged: (value) => _confirmQuantity(),
      ),
              ],
            ),
          );
        }


  Widget _buildSellButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: confirmedQuantity != null ? _showConfirmationDialog : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF67CA98),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('매도하기', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

  Widget _buildErrorMessageWidget() {
    return Text(_errorMessage ?? '', style: TextStyle(color: Colors.red, fontSize: 16));
  }
}
