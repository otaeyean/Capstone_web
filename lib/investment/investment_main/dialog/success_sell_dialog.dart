import 'package:flutter/material.dart';

class SuccessSellDialog extends StatefulWidget {
  @override
  _SuccessSellDialogState createState() => _SuccessSellDialogState();
}

class _SuccessSellDialogState extends State<SuccessSellDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      reverseDuration: Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _sizeAnimation = Tween<double>(begin: 50, end: 70).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        width: 300,
        height: 200,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _sizeAnimation,
              builder: (_, __) => Icon(Icons.celebration, color: Colors.orange, size: _sizeAnimation.value),
            ),
            SizedBox(height: 20),
            Text("매도가 완료되었습니다!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
