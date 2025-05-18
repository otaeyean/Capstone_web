import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'buy_price_buttons.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';

class BuyReservationSettingsScreen extends StatefulWidget {
  final double currentPrice;
  final String stockCode;

  BuyReservationSettingsScreen({
    required this.currentPrice,
    required this.stockCode,
  });

  @override
  _BuyReservationSettingsScreenState createState() =>_BuyReservationSettingsScreenState();
}

class _BuyReservationSettingsScreenState
    extends State<BuyReservationSettingsScreen> {
  late double _currentPrice;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  int _quantity = 1;
  String _stockCode = '';
  String _userId = '';
  String? userId;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.currentPrice;
    _stockCode = widget.stockCode;
    _priceController = TextEditingController(text: _currentPrice.toStringAsFixed(0));
    _quantityController = TextEditingController(text: '1');
    _loadUserId();
  }

  @override
  void didUpdateWidget(BuyReservationSettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPrice != oldWidget.currentPrice) {
      setState(() {
        _currentPrice = widget.currentPrice;
        _priceController.text = _currentPrice.toStringAsFixed(0);
      });
    }
    if (widget.stockCode != oldWidget.stockCode) {
      setState(() {
        _stockCode = widget.stockCode;
      });
    }
  }

  bool get _isForeignStock {
  return _stockCode.contains(RegExp(r'[A-Za-z]'));
}

  void _increasePrice(double percentage) {
    setState(() {
      _currentPrice += _currentPrice * (percentage / 100);
      _priceController.text = _currentPrice.toStringAsFixed(0);
    });
  }

  void _decreasePrice(double percentage) {
    setState(() {
      _currentPrice -= _currentPrice * (percentage / 100);
      _priceController.text = _currentPrice.toStringAsFixed(0);
    });
  }

  Future<void> _loadUserId() async {
    String? id = await AuthService.getUserId();
    if (id != null) {
      setState(() {
        userId = id;
        _userId = id; 
      });
    }
  }

  Future<void> _reserve() async {
    if (userId == null || userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.')),
      );
      return;
    }

    final url = Uri.parse('http://withyou.me:8080/stock/reserve/sell');
    final headers = {
      'Content-Type': 'application/json',
      'accept': '*/*',
    };
    final body = jsonEncode({
      'userId': userId,  
      'stockCode': _stockCode,
      'quantity': _quantity,
      'targetPrice': _currentPrice.toInt(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('매도 예약이 성공적으로 완료되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('예약 중 오류가 발생했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '매도 예약하기',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: '가격을 설정해주세요',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _currentPrice = double.tryParse(value) ?? _currentPrice;
                    });
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: '수량을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _quantity = int.tryParse(value) ?? 1;
                    });
                  },
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _reserve,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF67CA98),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, color: Colors.yellow),
                    SizedBox(width: 8),
                    Text(
                      '예약하기',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          PriceAdjustmentButtons(
            onIncrease: _increasePrice,
            onDecrease: _decreasePrice,
          ),
          SizedBox(height: 20),
         Text(
          '설정된 가격: ${_isForeignStock ? '\$${_currentPrice.toStringAsFixed(2)}' : '${_currentPrice.toStringAsFixed(0)}원'}, 수량: $_quantity주',
          style: TextStyle(fontSize: 18),
        ),
        ],
      ),
    );
  }
}

