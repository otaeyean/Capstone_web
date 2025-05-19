import 'package:flutter/material.dart';
import 'package:stockapp/investment/chart/stock_price.dart';
import 'package:stockapp/investment/chart/stock_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'moving_average_calculator.dart';
import 'package:intl/intl.dart';
import 'stock_chart_controls.dart';

class StockChartView extends StatefulWidget {
  final StockProvider stockProvider;
  final String stockCode;

  const StockChartView({Key? key, required this.stockProvider, required this.stockCode}) : super(key: key);

  @override
  _StockChartViewState createState() => _StockChartViewState();
}

class _StockChartViewState extends State<StockChartView> {
  double _zoomLevel = 1.0;

  final ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
    enablePinching: true,
    enablePanning: true,
    zoomMode: ZoomMode.x,
  );

  void _updateZoom(bool zoomIn) {
    setState(() {
      _zoomLevel = zoomIn ? (_zoomLevel * 1.2).clamp(1.0, 3.0) : (_zoomLevel / 1.2).clamp(1.0, 3.0);
    });
  }

  late TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    super.initState();
    widget.stockProvider.loadStockData(widget.stockCode, period: widget.stockProvider.selectedPeriod);
    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
      shouldAlwaysShow: false,
      lineType: TrackballLineType.none,
      markerSettings: TrackballMarkerSettings(markerVisibility: TrackballVisibilityMode.hidden),
      builder: (context, details) {
        if (details.seriesIndex != 0) return const SizedBox.shrink();
        final stock = widget.stockProvider.stockPrices.firstWhere(
          (s) => s.date == details.point?.x,
          orElse: () => widget.stockProvider.stockPrices.first,
        );
        final isMinute = widget.stockProvider.selectedPeriod == "1m";
        final timeStr = isMinute
            ? DateFormat('HH:mm').format(stock.date)
            : DateFormat('yyyy-MM-dd').format(stock.date);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFF1E2A38),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Color(0xFF67CA98), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(timeStr, style: TextStyle(color: Color(0xFF67CA98), fontSize: 14, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _infoText('시가', stock.open),
              _infoText('고가', stock.high),
              _infoText('저가', stock.low),
              _infoText('종가', stock.close),
            ],
          ),
        );
      },
    );
  }

  Widget _infoText(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: ${value.toStringAsFixed(0)}',
        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stockProvider = widget.stockProvider;
        final filteredData = stockProvider.stockPrices
            .where((stock) => stock.volume > 0)
            .toList()
            .reversed
            .toList();

        if (filteredData.isEmpty) return Center(child: Text('데이터 없음'));

        final maxPrice = filteredData.map((s) => s.high).reduce((a, b) => a > b ? a : b);
        final maxVolume = filteredData.map((s) => s.volume.toDouble()).reduce((a, b) => a > b ? a : b);
        final isMinuteChart = stockProvider.selectedPeriod == "1m";
        final format = isMinuteChart
            ? "HH:mm"
            : stockProvider.selectedPeriod == "M"
                ? "yyyy-MM"
                : "MM-dd";

        final tradingDays = filteredData.map((s) => DateFormat(format).format(s.date)).toList();
        final ma5 = calculateMovingAverage(filteredData, 5);
        final ma10 = calculateMovingAverage(filteredData, 10);
        final ma30 = calculateMovingAverage(filteredData, 30);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 50), // ✅ 차트 아래로

            Container(
              height: 60,
              color: Colors.white,
              child: Center(
                child: StockChartControls(
                  selectedPeriod: stockProvider.selectedPeriod,
                  onPeriodSelected: (period) => stockProvider.loadStockData(widget.stockCode, period: period),
                  onZoom: _updateZoom,
                ),
              ),
            ),

            /// 📈 캔들차트
            Container(
              width: MediaQuery.of(context).size.width, // ✅ 양쪽 여백 제거
              height: 280, // ✅ 세로 비율 축소
              child: SfCartesianChart(
                trackballBehavior: _trackballBehavior,
                zoomPanBehavior: _zoomPanBehavior,
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(width: 1, dashArray: [4, 4], color: Colors.grey[300]),
                  majorTickLines: MajorTickLines(width: 0),
                  labelStyle: TextStyle(color: Colors.transparent),
                  axisLine: AxisLine(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  opposedPosition: true,
                  minimum: isMinuteChart
                      ? filteredData.map((s) => s.low).reduce((a, b) => a < b ? a : b) * 0.98
                      : 0,
                  maximum: isMinuteChart
                      ? filteredData.map((s) => s.high).reduce((a, b) => a > b ? a : b) * 1.02
                      : maxPrice * 1.2,
                  majorGridLines: MajorGridLines(width: 0),
                ),
                series: <CartesianSeries>[
                  CandleSeries<StockPrice, dynamic>(
                    dataSource: filteredData,
                    xValueMapper: (s, i) => isMinuteChart ? s.date : tradingDays[i],
                    lowValueMapper: (s, _) => s.low,
                    highValueMapper: (s, _) => s.high,
                    openValueMapper: (s, _) => s.open,
                    closeValueMapper: (s, _) => s.close,
                    bearColor: Colors.blue.withOpacity(0.8),
                    bullColor: Colors.red.withOpacity(0.8),
                    enableSolidCandles: true,
                  ),
                  LineSeries<StockPrice, dynamic>(
                    dataSource: ma5,
                    xValueMapper: (s, i) => isMinuteChart ? s.date : tradingDays[i],
                    yValueMapper: (s, _) => s.close,
                    color: Colors.yellow,
                    width: 1,
                  ),
                  LineSeries<StockPrice, dynamic>(
                    dataSource: ma10,
                    xValueMapper: (s, i) => isMinuteChart ? s.date : tradingDays[i],
                    yValueMapper: (s, _) => s.close,
                    color: Colors.purple,
                    width: 1.5,
                  ),
                  LineSeries<StockPrice, dynamic>(
                    dataSource: ma30,
                    xValueMapper: (s, i) => isMinuteChart ? s.date : tradingDays[i],
                    yValueMapper: (s, _) => s.close,
                    color: Colors.green,
                    width: 1.5,
                  ),
                ],
              ),
            ),

            /// 📊 거래량 차트
            Container(
              width: MediaQuery.of(context).size.width, // ✅ 여백 제거
              height: 160,
              child: SfCartesianChart(
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  majorTickLines: MajorTickLines(width: 0),
                  labelStyle: TextStyle(fontSize: 10),
                  axisLine: AxisLine(width: 1, color: Colors.grey[400]),
                ),
                primaryYAxis: NumericAxis(
                  opposedPosition: true,
                  minimum: 0,
                  maximum: maxVolume * 1.2,
                  axisLine: AxisLine(width: 0),
                  majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey),
                  labelStyle: TextStyle(fontSize: 10),
                ),
                series: <CartesianSeries>[
                  ColumnSeries<StockPrice, dynamic>(
                    dataSource: filteredData,
                    xValueMapper: (s, i) => isMinuteChart ? s.date : tradingDays[i],
                    yValueMapper: (s, _) => s.volume.toDouble(),
                    pointColorMapper: (s, _) => s.close > s.open ? Colors.red : Colors.blue,
                    width: 0.6,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
