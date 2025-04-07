import 'package:flutter/material.dart';

class StockChangeInfo extends StatelessWidget {
  final Map<String, dynamic> stock;
  StockChangeInfo({required this.stock});

  @override
  Widget build(BuildContext context) {
    double changeValue = (stock['change_value'] ?? 0.0).toDouble();
    double risePercent = (stock['rise_percent'] ?? 0.0).toDouble();
    double fallPercent = (stock['fall_percent'] ?? 0.0).toDouble();

    bool isPositive = changeValue > 0;

    return Text(
      '어제보다 ${isPositive ? '+' : ''}${changeValue.toStringAsFixed(0)}원 '
      '(${isPositive ? risePercent.toStringAsFixed(2) : fallPercent.toStringAsFixed(2)}%)',
      style: TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    );
  }
}

