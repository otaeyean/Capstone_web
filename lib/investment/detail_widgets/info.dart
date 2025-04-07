import 'package:flutter/material.dart';

class StockInfo extends StatelessWidget {
  final Map<String, dynamic> stock;
  StockInfo({required this.stock});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stock['name'],
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          '${stock['price']}원',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}