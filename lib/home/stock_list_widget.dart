import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_model.dart'; // UserStockModel import

class StockListWidget extends StatefulWidget {
  final List<UserStockModel> stocks; // 🔥 실제 데이터 받기

  const StockListWidget({Key? key, required this.stocks}) : super(key: key);

  @override
  _StockListWidgetState createState() => _StockListWidgetState();
}

class _StockListWidgetState extends State<StockListWidget> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (widget.stocks.length / 4).ceil();

    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * 4;
              final endIndex = (startIndex + 4).clamp(0, widget.stocks.length);
              final pageStocks = widget.stocks.sublist(startIndex, endIndex);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildStockCard(pageStocks[0]),
                        SizedBox(width: 10), // 여백 추가
                        if (pageStocks.length > 1) buildStockCard(pageStocks[1]),
                      ],
                    ),
                    SizedBox(height: 10), // Row 사이의 간격 추가
                    if (pageStocks.length > 2)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildStockCard(pageStocks[2]),
                          SizedBox(width: 10), // 여백 추가
                          if (pageStocks.length > 3) buildStockCard(pageStocks[3]),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10),
        _buildPageIndicator(totalPages),
      ],
    );
  }

  Widget buildStockCard(UserStockModel stock) {
    final price = stock.price ?? 0.0;
    final profitRate = stock.profitRate ?? 0.0;
    final profitText = "${profitRate >= 0 ? "+" : ""}${profitRate.toStringAsFixed(2)}%";
    final changeColor = profitRate >= 0 ? Colors.red : Colors.blue;

   return Expanded(
  child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Color(0xFFEFF9F8 ), // 배경색
      borderRadius: BorderRadius.circular(8), // 둥근 모서리
      border: Border.all(color: Colors.grey[100]!, width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          stock.name ?? '이름 없음',
          style: TextStyle(
            fontFamily: 'MinSans', 
            fontWeight: FontWeight.w900, 
            fontSize: 16,
            color:Color(0xFF03314B ), // 텍스트 색상을 흰색으로 변경
          ),
        ),
        SizedBox(height: 4),
        Text(
          "${price.toStringAsFixed(0)}원",
          style: TextStyle(
            fontSize: 14, 
            fontFamily: 'MinSans', 
            fontWeight: FontWeight.w900,
            color: Color(0xFF03314B ), // 텍스트 색상을 흰색으로 변경
          ),
        ),
        Text(
          profitText,
          style: TextStyle(
            fontFamily: 'MinSans',
            fontWeight: FontWeight.w900,
            color: changeColor,
          ),
        ),
      ],
    ),
  ),
);

  }

  Widget _buildPageIndicator(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            setState(() {
              _currentPage = index;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              index == _currentPage ? "●" : "○",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        );
      }),
    );
  }
}
