import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_model.dart';
import 'package:stockapp/user_info/user_info_screen.dart';

class StockListWidget extends StatelessWidget {
  final List<UserStockModel>? stocks;
  final bool isLoading;

  const StockListWidget({
    Key? key,
    required this.stocks,
    this.isLoading = false,
  }) : super(key: key);
@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타이틀
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // ✅ 수직 정렬
            children: [
              Icon(
               Icons.face ,  // ✅ 귀엽고 통용될 수 있는 아이콘 (⭐)
                color: Color(0xFF0F1E46),
                size: 24,
              ),
              SizedBox(width: 8),  // 아이콘과 텍스트 사이 공간
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '투자 종목',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'MinSans',
                          color: Colors.green, // ✅ 초록색 강조
                        ),
                      ),
                      TextSpan(
                        text: ' 한 눈에 보기',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'MinSans',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        SizedBox(
          height: 130,
          child: isLoading
              ? _buildLoadingList()
              : (stocks == null || stocks!.isEmpty)
                  ? _buildEmptyMessage()
                  : _buildStockList(context),
        ),
      ],
    ),
  );
}


  Widget _buildLoadingList() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      padding: EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (_, __) => SizedBox(width: 40),
      itemBuilder: (_, __) => Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: 64,
            height: 14,
            color: Colors.grey[300],
          ),
          SizedBox(height: 4),
          Container(
            width: 64,
            height: 12,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage() {
    return Center(
      child: Text(
        "보유한 종목이 없습니다",
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
          fontFamily: 'MinSans',
        ),
      ),
    );
  }

  Widget _buildStockList(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: stocks!.length,
      padding: EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (context, index) => SizedBox(width: 24),
      itemBuilder: (context, index) {
        final stock = stocks![index];
        final profitRate = stock.profitRate ?? 0.0;
        final profitText =
            "${profitRate >= 0 ? "+" : ""}${profitRate.toStringAsFixed(2)}%";
        final changeColor = profitRate >= 0 ? Colors.red : Colors.blue;
        final stockImage = 'assets/images/${stock.name}_${stock.stockCode}.png';

        return GestureDetector(
          behavior: HitTestBehavior.opaque, // ✅ 빈 공간까지 클릭 허용
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserInfoScreen(),
              ),
            );
          },
          child: SizedBox(
            width: 80, // ✅ 넓게 터치영역 설정
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF4F4F6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        stockImage,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.business,
                            color: Colors.black45,
                            size: 32,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: 64,
                  child: Text(
                    stock.name ?? '이름 없음',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'MinSans',
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    profitText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'MinSans',
                      color: changeColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}