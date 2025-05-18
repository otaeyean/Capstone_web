import 'package:flutter/material.dart';
import 'company_service.dart';
import 'stock_item.dart';

class CompanyListPage extends StatefulWidget {
  final String category;

  const CompanyListPage({Key? key, required this.category}) : super(key: key);

  @override
  _CompanyListPageState createState() => _CompanyListPageState();
}

class _CompanyListPageState extends State<CompanyListPage> {
  List<StockItem> stockList = [];
  bool isLoading = true;

  final Color cardColor = const Color(0xFFFFFDF8); // ✔️ 원래 연한 크림톤으로 되돌림
  final Color textColor = const Color(0xFF3A3A3A);
  final Color iconColor = const Color(0xFF2B3A55); // 딥네이비

  @override
  void initState() {
    super.initState();
    fetchStockList();
  }

  Future<void> fetchStockList() async {
    try {
      final result = await CompanyService.fetchStockListByCategory(widget.category);
      setState(() {
        stockList = result;
        isLoading = false;
      });
    } catch (e) {
      print("[에러] $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildStockCard(String name) {
    return InkWell(
      onTap: () {}, // 향후 확장 가능
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.07)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.format_list_bulleted, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'MinSans',
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: Text(
          '${widget.category} 관련 종목',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            fontFamily: 'MinSans',
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.8,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stockList.isEmpty
              ? const Center(
                  child: Text(
                    '해당 카테고리에 종목이 없습니다.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'MinSans',
                      color: Colors.grey,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8), // 제목과 리스트 간 여백
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 3.8,
                          children: stockList.map((e) => buildStockCard(e.stockName)).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
