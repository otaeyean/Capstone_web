import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  final String userId; 

  UserProfile({required this.userId}); 

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 52, color: Colors.black),
        ),
        SizedBox(width: 10),
        Text(
          "$userId 님!\n즐거운 주식 되세요", 
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)
         
        ),
      ],
    );
  }
}
