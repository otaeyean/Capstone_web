// price_adjustment_buttons.dart

import 'package:flutter/material.dart';

class PriceAdjustmentButtons extends StatelessWidget {
  final Function(double) onIncrease;
  final Function(double) onDecrease;

  const PriceAdjustmentButtons({
    Key? key,
    required this.onIncrease,
    required this.onDecrease,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildStyledButton(Icons.add, '3%', () => onIncrease(3)),
            SizedBox(width: 10),
            _buildStyledButton(Icons.add, '5%', () => onIncrease(5)),
            SizedBox(width: 10),
            _buildStyledButton(Icons.add, '10%', () => onIncrease(10)),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            _buildStyledButton(Icons.remove, '3%', () => onDecrease(3)),
            SizedBox(width: 10),
            _buildStyledButton(Icons.remove, '5%', () => onDecrease(5)),
            SizedBox(width: 10),
            _buildStyledButton(Icons.remove, '10%', () => onDecrease(10)),
          ],
        ),
      ],
    );
  }

  Widget _buildStyledButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.green),
      label: Text(
        '$label',
        style: TextStyle(color: Colors.black),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Color.fromARGB(255, 57, 204, 79), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}
