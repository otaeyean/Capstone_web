import 'package:flutter/material.dart';

class StockDescription extends StatelessWidget {
  final Map<String, dynamic> stock;
  final String description;

  const StockDescription({required this.stock, required this.description, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${stock['name']} 회사 소개',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFF22B379), width: 2), 
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.business, 
                        color: Color(0xFF22B379), 
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '회사 소개',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22B379),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
