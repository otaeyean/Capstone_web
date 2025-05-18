import 'package:flutter/material.dart';
class ConfirmationDialog extends StatelessWidget {
  final String price; 
  final int quantity;
  final VoidCallback onConfirm;

  ConfirmationDialog({
    required this.price,
    required this.quantity,
    required this.onConfirm,
  });

  bool get _isWon => price.contains('원');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text("매수 확인"),
          SizedBox(width: 8),
          Icon(Icons.help_outline, color: Colors.black),
        ],
      ),
      content: Text(
        "체결 가격: $price\n구매 수량: $quantity 주\n\n진행하시겠습니까?",
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("취소", style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text("확인", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
