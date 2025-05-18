import 'package:flutter/material.dart';
class StockSortHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Divider(
        color: Color(0xFFE0E0E0),
        thickness: 1.2,
        endIndent: 50,
      ),
    );
  }
}
