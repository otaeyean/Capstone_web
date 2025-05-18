import 'package:flutter/material.dart';

class StockInfo extends StatelessWidget {
  final Map<String, dynamic> stock;

  const StockInfo({required this.stock, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String stockCode = stock['stockCode'] ?? '';
    final String stockName = stock['name'] ?? '이름 없음';
    final bool isOverseas = stockCode.contains(RegExp(r'[A-Za-z]'));

    final String priceText = isOverseas
        ? '\$${stock['price']}'
        : '${stock['price']}원';

    final String imagePath = 'assets/images/${stockName}_${stockCode}.png';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ 동그란 로고 이미지
        Container(
          width: 56,
          height: 56,
          margin: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFEFF9F8),
          ),
          child: ClipOval(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.broken_image, size: 30, color: Colors.grey),
            ),
          ),
        ),
        // ✅ 텍스트 정보
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stockName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              priceText,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
