class StockItem {
  final String categoryName;
  final String stockName;
  final double deviation;

  StockItem({
    required this.categoryName,
    required this.stockName,
    required this.deviation,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      categoryName: json['categoryName'],
      stockName: json['stockName'],
      deviation: (json['deviation'] as num).toDouble(),
    );
  }
}
