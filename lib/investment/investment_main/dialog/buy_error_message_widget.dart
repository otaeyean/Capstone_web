import 'package:flutter/material.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String? errorMessage;

  ErrorMessageWidget({this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: errorMessage != null ? 1.0 : 0.0, 
      duration: Duration(seconds: 1), 
      child: Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        width: double.infinity,
        child: Text(
          errorMessage!,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
