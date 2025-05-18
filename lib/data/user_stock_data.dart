import 'dart:convert';
 import 'package:flutter/services.dart';
 
 class UserStockData {
   String name;
   String ticker;
   double price;
   int quantity;
   double totalValue;
   double risePercent;  // 상승률
   double fallPercent;  // 하락률
   double profitRate;   // 수익률 (총 평가 대비 수익률)
 
   UserStockData({
     required this.name,
     required this.ticker,
     required this.price,
     required this.quantity,
     required this.risePercent,
     required this.fallPercent,
   })  : totalValue = price * quantity,
         profitRate = (risePercent > 0 ? risePercent : -fallPercent); // 상승률이 있으면 양수, 하락률이 있으면 음수
 
   // JSON 데이터를 객체로 변환하는 팩토리 생성자
   factory UserStockData.fromJson(Map<String, dynamic> json) {
     return UserStockData(
       name: json['name'],
       ticker: json['ticker'],
       price: (json['price'] as num).toDouble(),
       quantity: json['quantity'] as int,
       risePercent: (json['rise_percent'] ?? 0.0).toDouble(),
       fallPercent: (json['fall_percent'] ?? 0.0).toDouble(),
     );
   }
 }
 
 // JSON 데이터를 로드하는 함수
 Future<List<UserStockData>> loadUserStockData() async {
   // JSON 파일 읽기
   String jsonString = await rootBundle.loadString('assets/user_stock_data.json');
   final data = jsonDecode(jsonString);
 
   // JSON 데이터를 UserStockData 객체 리스트로 변환
   List<UserStockData> userStocks = (data['stocks'] as List)
       .map((stockJson) => UserStockData.fromJson(stockJson))
       .toList();
 
   return userStocks;
 }