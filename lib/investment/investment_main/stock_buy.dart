import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockapp/server/investment/user_balance_server.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/server/investment/stock_buy_server.dart';
import 'package:stockapp/investment/investment_main/dialog/success_purchase_dialog.dart';
import 'dialog/buy_error_message_widget.dart'; 
import 'dialog/buy_confirmation_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import '../investment_main/reservation/reservation_buy_settings.dart';

class MockBuyScreen extends StatefulWidget {
  final String stockCode;

  MockBuyScreen({required this.stockCode});

  @override
  _MockBuyScreenState createState() => _MockBuyScreenState();
}

class _MockBuyScreenState extends State<MockBuyScreen> {
  TextEditingController _quantityController = TextEditingController();
  final UserBalanceService _balanceService = UserBalanceService();
  double? _balance;
  double? _price;  
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

  // 서버에서 현재가를 가져오는 함수
  Future<void> _fetchStockPrice() async {
    final response = await http.get(Uri.parse('http://withyou.me:8080/current-price?stockCode=${widget.stockCode}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _price = data['stockPrice']?.toDouble() ?? 0.0;
      });
    } else {
      setState(() {
        _errorMessage = "현재가를 가져오지 못했습니다.";
      });
    }
  }

  Future<void> _buyStock() async {
    if (userId == null || confirmedQuantity == null) {
      setState(() {
        _errorMessage = "로그인을 확인하거나 수량을 입력하세요.";
      });
      return;
    }

    if (_balance != null && _balance! < (_price! * confirmedQuantity!)) {
      setState(() {
        _errorMessage = "보유 금액이 부족합니다.";
      });
      return;
    }

    bool success = await StockServer.buyStock(userId!, widget.stockCode, confirmedQuantity!);
    if (success) {
      print("구매 성공");
      _loadBalance(userId!);
      setState(() {
        confirmedQuantity = null;
        _errorMessage = null;
      });
      _showSuccessDialog();
    } else {
      print("구매 실패");
      setState(() {
        _errorMessage = "매수 실패. 다시 시도해주세요.";
      });
    }
  }

bool get _isForeignStock {
  return widget.stockCode.contains(RegExp(r'[A-Za-z]'));
}

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AnimatedSuccessDialog();
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
        _errorMessage = null;
      });
    }
  }
  
_showConfirmationDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final isForeign = widget.stockCode.contains(RegExp(r'[A-Za-z]'));
      final formattedPrice = isForeign
          ? '\$${_price!.toStringAsFixed(2)}'
          : '${_price!.toStringAsFixed(0)}원';

      return ConfirmationDialog(
        price: formattedPrice,
        quantity: confirmedQuantity!,
        onConfirm: () {
          Navigator.of(context).pop();
          _buyStock();
        },
      );
    },
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea( // (선택) 화면이 노치나 상태바를 침범하지 않게
      child: SingleChildScrollView( // <- 추가
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
              Container(
                width: double.infinity,
                child: Divider(
                  color: Colors.grey,
                  thickness: 1,
                  height: 1,
                ),
              ),
              ReservationSettingsScreen(
                currentPrice: _price ?? 0.0,
                stockCode: widget.stockCode,
              ),
              SizedBox(height: 30),
              _buildBuyButton(), // Spacer()는 삭제해야 함
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
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(187, 0, 0, 0),  // 보유 금액 텍스트 색
            ),
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
          hintText: '몇 주 매수할까요?',
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

  Widget _buildBuyButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: confirmedQuantity != null ? _showConfirmationDialog : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF67CA98),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('매수하기', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

  Widget _buildErrorMessageWidget() {
    return ErrorMessageWidget(errorMessage: _errorMessage);
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }
}
