import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stock_provider.dart';
import 'stock_chart_view.dart';

class StockChartMain extends StatefulWidget {
  final String stockCode;

  const StockChartMain({Key? key, required this.stockCode}) : super(key: key);

  @override
  _StockChartMainState createState() => _StockChartMainState();
}

class _StockChartMainState extends State<StockChartMain> {
  String _selectedPeriod = "D";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<StockProvider>(context, listen: false)
          .loadStockData(widget.stockCode, period: _selectedPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        if (stockProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (stockProvider.errorMessage.isNotEmpty) {
          return Center(
            child: Text(stockProvider.errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)),
          );
        }

        if (stockProvider.stockPrices.isEmpty) {
          return const Center(child: Text("No stock data available"));
        }

        return SingleChildScrollView( // 세로 스크롤을 가능하게 만듦
          child: Column(
            children: [
              StockChartView(stockProvider: stockProvider, stockCode: widget.stockCode), // stockCode 전달
            ],
          ),
        );
      },
    );
  }
}