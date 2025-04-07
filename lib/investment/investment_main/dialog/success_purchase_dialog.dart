import 'package:flutter/material.dart';

class AnimatedSuccessDialog extends StatefulWidget {
  @override
  _AnimatedSuccessDialogState createState() => _AnimatedSuccessDialogState();
}

class _AnimatedSuccessDialogState extends State<AnimatedSuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _sizeAnimation = Tween<double>(begin: 50, end: 70).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        _controller.reverse().whenComplete(() {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
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
              builder: (context, child) {
                return Icon(Icons.celebration, color: Colors.orange, size: _sizeAnimation.value);
              },
            ),
            SizedBox(height: 20),
            Text("구매가 완료되었습니다!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("성공적인 투자이길 바랍니다", style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
