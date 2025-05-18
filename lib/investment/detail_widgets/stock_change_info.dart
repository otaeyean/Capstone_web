import 'package:flutter/material.dart';

double toDoubleSafe(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final cleaned = value.replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }
  return 0.0;
}

class StockChangeInfo extends StatelessWidget {
  final Map<String, dynamic> stock;

  const StockChangeInfo({required this.stock, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double price = toDoubleSafe(
        stock['stockCurrentPrice'] ?? stock['currentPrice'] ?? stock['price']);
    final double changeValue = toDoubleSafe(
        stock['stockChange'] ?? stock['changePrice'] ?? stock['change_value']);
    final double percent = toDoubleSafe(
        stock['stockChangePercent'] ?? stock['changeRate'] ?? stock['rise_percent'] ?? stock['fall_percent']);

    if (price == 0) {
      return _styledInfoBox(
        text: '가격 정보 없음',
        backgroundColor: Colors.grey[100]!,
        textColor: Colors.grey[600]!,
      );
    }

    if (changeValue == 0 && percent == 0) {
      return _styledInfoBox(
        text: '어제보다 변동 없음 (0.00%)',
        backgroundColor: Colors.grey[100]!,
        textColor: Colors.grey[600]!,
      );
    }

    final bool isPositive = changeValue > 0 || percent > 0;
    final String changePrefix = isPositive ? '+' : '';
    final String percentText = '(${percent.toStringAsFixed(2)}%)';

    return _styledInfoBox(
      text: '어제보다$percentText',
      backgroundColor: isPositive ? Color(0xFFFFEEF0) : Color(0xFFE8F2FF),
      textColor: isPositive ? Colors.red : Colors.blue,
    );
  }

  Widget _styledInfoBox({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
