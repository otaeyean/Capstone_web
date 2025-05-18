class UserStockModel {
   final String stockCode;
   final String name;
   final double price;
   final double averagePurchasePrice;
   final double profitAmount;
   final double profitRate;
   final double totalValue;
   final int quantity;
 
   UserStockModel({
     required this.stockCode,
     required this.name,
     required this.price,
     required this.averagePurchasePrice,
     required this.profitAmount,
     required this.profitRate,
     required this.totalValue,
     required this.quantity,
   });
 
  
   factory UserStockModel.fromJson(Map<String, dynamic> json) {
     return UserStockModel(
       stockCode: json['stockCode'],
       name: json['stockName'],
       price: json['currentPrice'].toDouble(),
       averagePurchasePrice: json['averagePurchasePrice'].toDouble(),
       profitAmount: json['profitAmount'].toDouble(),
       profitRate: json['profitRate'].toDouble(),
       totalValue: json['totalAmount'].toDouble(),
       quantity: json['quantity'],
     );
   }
 }