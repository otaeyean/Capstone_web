import 'package:flutter/material.dart';
import 'chart_server.dart';
import 'stock_price.dart';

class StockProvider with ChangeNotifier {
  final ChartService _chartService = ChartService();
  List<StockPrice> _stockPrices = [];
  bool _isLoading = false;
  String _errorMessage = "";
  String _selectedPeriod = "D"; // ✅ 기본값: "D" (일봉)

  List<StockPrice> get stockPrices => _stockPrices;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedPeriod => _selectedPeriod;

  Future<void> loadStockData(String stockCode, {String period = "D"}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = "";
    _selectedPeriod = period; // ✅ 선택한 기간 저장
    notifyListeners();

    try {
      if (period == "1m") {
        // ✅ 1분봉 데이터 여러 개 불러오기
        _stockPrices = await _chartService.fetchMinuteChartData(stockCode, time: 1);
        if (_stockPrices.length < 2) {
          _errorMessage = "1분봉 데이터가 부족합니다.";
        }
      } else {
        _stockPrices = await _chartService.fetchChartData(stockCode, period: period);
      }
    } catch (error) {
  
      _errorMessage = "주식 데이터를 불러오는 데 실패했습니다.";
    }

    _isLoading = false;
    notifyListeners();
  }
}
