import 'package:flutter/material.dart';
import 'package:stockapp/investment/stock_detail_screen.dart';

class SearchableStockList extends StatefulWidget {
  final List<Map<String, dynamic>> stockList;

  SearchableStockList({required this.stockList});

  @override
  _SearchableStockListState createState() => _SearchableStockListState();
}

class _SearchableStockListState extends State<SearchableStockList> {
  List<Map<String, dynamic>> filteredStocks = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredStocks = [];
  }

  void _filterStocks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStocks = [];
      } else {
        filteredStocks = widget.stockList
            .where((stock) => stock['stockName']!
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ 검색창
        TextField(
          controller: _controller,
          onChanged: _filterStocks,
          decoration: InputDecoration(
            hintText: '원하는 종목을 검색해보세요',
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          ),
          style: TextStyle(fontSize: 16),
        ),

        SizedBox(height: 10),

        // ✅ 자동완성 리스트
        if (filteredStocks.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            constraints: BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: filteredStocks.length,
              itemBuilder: (context, index) {
                final selected = filteredStocks[index];

                // ✅ 가격 및 변동률 필드 보강
                final enrichedStock = {
                  ...selected,
                  'currentPrice': selected['stockCurrentPrice'] ??
                      selected['currentPrice'] ??
                      selected['price'] ??
                      0,
                  'changeRate': selected['stockChangePercent'] ??
                      selected['changeRate'] ??
                      selected['rise_percent'] ??
                      selected['fall_percent'] ??
                      0,
                  'tradeVolume': selected['acml_vol'] ??
                      selected['tradeVolume'] ??
                      0,
                };

                return ListTile(
                  title: Text(
                    enrichedStock['stockName'] ?? '이름 없음',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    print("🔍 선택된 검색 결과: $selected"); // 이 줄을 추가!
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StockDetailScreen(stock: enrichedStock),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
