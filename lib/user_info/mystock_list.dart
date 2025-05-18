import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_model.dart';
import 'package:stockapp/investment/stock_detail_screen.dart';
import 'package:intl/intl.dart';

class MyStockList extends StatelessWidget {
  final List<UserStockModel> stocks;

  MyStockList({required this.stocks});
  final formatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    return stocks.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                "보유한 주식이 없습니다.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              var stock = stocks[index];
              String stockName = stock.name ?? '상장이 폐지되었습니다';
              double stockPrice = stock.price ?? 0.0;
              double stockProfitRate = stock.profitRate ?? 0.0;
              int stockQuantity = stock.quantity ?? 0;
              double totalValue = stock.totalValue ?? 0.0;
              String stockCode = stock.stockCode ?? '';

              return Padding(
                padding: EdgeInsets.fromLTRB(16, index == 0 ? 12 : 8, 16, 8),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  shadowColor: Colors.black12,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockDetailScreen(
                            stock: {
                              'stockName': stockName,
                              'currentPrice': stockPrice.toString(),
                              'changeRate': stockProfitRate.toString(),
                              'tradeVolume': stockQuantity.toString(),
                              'stockCode': stockCode,
                            },
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 왼쪽: 종목 이미지 + 이름/수량
                          Row(
                            children: [
                              // ✅ 동그란 이미지 추가
                              Container(
                                width: 40,
                                height: 40,
                                margin: EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFEFF9F8),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/${stockName}_${stockCode}.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.broken_image, color: Colors.grey, size: 24);
                                    },
                                  ),
                                ),
                              ),

                              // 종목명 및 보유량/총액
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stockName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF003366),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '$stockQuantity 주 · ${formatter.format(totalValue)} 원',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // 오른쪽: 현재가 + 수익률
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${formatter.format(stockPrice)} 원',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${stockProfitRate.toStringAsFixed(2)} %',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: stockProfitRate > 0
                                      ? Colors.redAccent
                                      : (stockProfitRate < 0
                                          ? Colors.blueAccent
                                          : Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}
