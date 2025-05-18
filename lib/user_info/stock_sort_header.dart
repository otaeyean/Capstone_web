import 'package:flutter/material.dart';

class StockSortHeader extends StatelessWidget {
  final String title;
  const StockSortHeader({this.title = '📄 전체 주식 리스트', super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFEEF9F5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.list_alt_rounded, color: Color(0xFF67CA98), size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A2E35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
