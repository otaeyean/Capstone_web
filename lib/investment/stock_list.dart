import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'stock_detail_screen.dart';

const Color primaryColor = Color(0xFF67CA98);
const Color backgroundColor = Color(0xFFF4F6F9);
const Color darkTextColor = Color(0xFF1A2E35);
const Color gainColor = Colors.red;
const Color lossColor = Colors.blue;

class StockList extends StatelessWidget {
  final List<Map<String, dynamic>> stocks;
  final bool isTradeVolumeSelected;

  const StockList({required this.stocks, required this.isTradeVolumeSelected});

  String formatTradeVolume(int volume) {
    return volume >= 1000000
        ? "${(volume / 1000000).toStringAsFixed(1)}M"
        : NumberFormat("#,###").format(volume);
  }

  String formatKoreanPrice(double price) {
    return NumberFormat("#,###").format(price);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: stocks.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _StockListItem(
          stock: stocks[index],
          isTradeVolumeSelected: isTradeVolumeSelected,
        );
      },
    );
  }
}

class _StockListItem extends StatefulWidget {
  final Map<String, dynamic> stock;
  final bool isTradeVolumeSelected;

  const _StockListItem({
    required this.stock,
    required this.isTradeVolumeSelected,
  });

  @override
  State<_StockListItem> createState() => _StockListItemState();
}

class _StockListItemState extends State<_StockListItem> {
  bool isHovered = false;

  String formatTradeVolume(int volume) {
    return volume >= 1000000
        ? "${(volume / 1000000).toStringAsFixed(1)}M"
        : NumberFormat("#,###").format(volume);
  }

  String formatKoreanPrice(double price) {
    return NumberFormat("#,###").format(price);
  }

  @override
  Widget build(BuildContext context) {
    var stock = widget.stock;

    double percent = (stock['stockChangePercent'] ?? stock['changeRate'] ?? 0).toDouble();
    double changePrice = (stock['stockChange'] ?? stock['changePrice'] ?? 0).toDouble();
    double currentPrice = (stock['stockCurrentPrice'] ?? stock['currentPrice'] ?? 0).toDouble();
    int tradeVolume = (stock['acml_vol'] ?? stock['tradeVolume'] ?? 0).toInt();

    bool isOverseas = stock.containsKey("excd") ||
        (stock['stockCode'] is String && RegExp(r'[A-Za-z]').hasMatch(stock['stockCode']));

    if (isOverseas && percent < 0) changePrice = -changePrice;

    String changeText = percent >= 0
        ? "+${percent.toStringAsFixed(2)}%"
        : "${percent.toStringAsFixed(2)}%";

    Color changeColor = percent >= 0 ? gainColor : lossColor;
    Color priceColor = widget.isTradeVolumeSelected ? Colors.black : changeColor;

    String priceText = isOverseas
        ? "\$${currentPrice.toStringAsFixed(2)}"
        : "${formatKoreanPrice(currentPrice)} 원";

    final enrichedStock = {
      ...stock,
      'currentPrice': stock['stockCurrentPrice'] ?? stock['currentPrice'] ?? stock['price'] ?? 0,
      'changeRate': stock['stockChangePercent'] ?? stock['changeRate'] ?? stock['rise_percent'] ?? stock['fall_percent'] ?? 0,
    };

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockDetailScreen(stock: enrichedStock),
            ),
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isHovered ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ 동그란 이미지
              Container(
                width: 48,
                height: 48,
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEFF9F8),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/${stock['stockName']}_${stock['stockCode']}.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.account_balance, color: Colors.grey, size: 24);
                    },
                  ),
                ),
              ),

              // ✅ 텍스트 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stock['stockName'] ?? '이름 없음',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkTextColor,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: percent >= 0
                                ? gainColor.withOpacity(0.1)
                                : lossColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            changeText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: changeColor,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          priceText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: priceColor,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.bar_chart, size: 16, color: Colors.grey[400]),
                            SizedBox(width: 4),
                            Text(
                              formatTradeVolume(tradeVolume),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
