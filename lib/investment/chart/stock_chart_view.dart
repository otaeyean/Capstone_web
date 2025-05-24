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
      if (zoomIn) {
        _zoomLevel = (_zoomLevel * 1.2).clamp(1.0, 3.0);
      } else {
        _zoomLevel = (_zoomLevel / 1.2).clamp(1.0, 3.0);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.stockProvider.loadStockData(widget.stockCode, period: widget.stockProvider.selectedPeriod);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double chartWidth = constraints.maxWidth * _zoomLevel;
        double chartHeight = 500 * _zoomLevel;

        List<StockPrice> filteredData = widget.stockProvider.stockPrices.where((stock) => stock.volume > 0).toList().reversed.toList();

        double maxPrice = filteredData.map((s) => s.high).reduce((a, b) => a > b ? a : b);
        double maxVolume = filteredData.map((s) => s.volume.toDouble()).reduce((a, b) => a > b ? a : b);

        bool isMinuteChart = widget.stockProvider.selectedPeriod == "1m";
        String dateFormatPattern = isMinuteChart ? "HH:mm" : widget.stockProvider.selectedPeriod == "M" ? "yyyy-MM" : "MM-dd";

        List<String> tradingDays = filteredData.map((stock) {
          return DateFormat(dateFormatPattern).format(stock.date);
        }).toList();

        List<StockPrice> ma5 = calculateMovingAverage(filteredData, 5);
        List<StockPrice> ma10 = calculateMovingAverage(filteredData, 10);
        List<StockPrice> ma30 = calculateMovingAverage(filteredData, 30);

        return Column(
          children: [
            Container(
              height: 60,
              color: Colors.white,
              child: Center(
                child: StockChartControls(
                  selectedPeriod: widget.stockProvider.selectedPeriod,
                  onPeriodSelected: (period) {
                    widget.stockProvider.loadStockData(widget.stockCode, period: period);
                  },
                  onZoom: _updateZoom,
                ),
              ),
            ),
            Stack(
              children: [
                Container(height: 3, width: chartWidth, color: Colors.grey[300]),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      SizedBox(
                        width: chartWidth,
                        height: chartHeight,
                        child: SfCartesianChart(
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
                              xValueMapper: (StockPrice stock, int index) =>
                                  isMinuteChart ? stock.date : tradingDays[index],
                              lowValueMapper: (StockPrice stock, _) => stock.low,
                              highValueMapper: (StockPrice stock, _) => stock.high,
                              openValueMapper: (StockPrice stock, _) => stock.open,
                              closeValueMapper: (StockPrice stock, _) => stock.close,
                              bearColor: Colors.blue.withOpacity(0.8),
                              bullColor: Colors.red.withOpacity(0.8),
                              enableSolidCandles: true,
                            ),
                            LineSeries<StockPrice, dynamic>(
                              dataSource: ma5,
                              xValueMapper: (StockPrice stock, int index) =>
                                  isMinuteChart ? stock.date : tradingDays[index],
                              yValueMapper: (StockPrice stock, _) => stock.close,
                              color: Colors.yellow,
                              width: 1,
                            ),
                            LineSeries<StockPrice, dynamic>(
                              dataSource: ma10,
                              xValueMapper: (StockPrice stock, int index) =>
                                  isMinuteChart ? stock.date : tradingDays[index],
                              yValueMapper: (StockPrice stock, _) => stock.close,
                              color: Colors.purple,
                              width: 1.5,
                            ),
                            LineSeries<StockPrice, dynamic>(
                              dataSource: ma30,
                              xValueMapper: (StockPrice stock, int index) =>
                                  isMinuteChart ? stock.date : tradingDays[index],
                              yValueMapper: (StockPrice stock, _) => stock.close,
                              color: Colors.green,
                              width: 1.5,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: chartWidth,
                        height: 180 * _zoomLevel,
                        child: SfCartesianChart(
                          margin: EdgeInsets.zero,
                          plotAreaBorderWidth: 0,
                          primaryXAxis: isMinuteChart
                              ? DateTimeAxis(
                                  dateFormat: DateFormat('HH:mm'),
                                  majorGridLines: MajorGridLines(width: 0),
                                  axisLine: AxisLine(width: 1, color: Colors.grey[400]),
                                )
                              : CategoryAxis(
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
                            majorTickLines: MajorTickLines(size: 0),
                            majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey),
                            labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          series: <CartesianSeries>[
                            ColumnSeries<StockPrice, dynamic>(
                              dataSource: filteredData,
                              xValueMapper: (StockPrice stock, int index) =>
                                  isMinuteChart ? stock.date : tradingDays[index],
                              yValueMapper: (StockPrice stock, _) => stock.volume.toDouble(),
                              pointColorMapper: (StockPrice stock, _) =>
                                  stock.close > stock.open ? Colors.red : Colors.blue,
                              width: 0.6,
                            ),
                          ],
                        ),
                      ),
                      Container(height: 3, width: chartWidth, color: Colors.grey[300]),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: chartWidth,
                        child: Container(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
                    ),
                    child: Row(
                      children: [
                        Row(children: [Container(width: 12, height: 12, color: Colors.yellow), SizedBox(width: 6), Text("5", style: TextStyle(fontSize: 14))]),
                        SizedBox(width: 14),
                        Row(children: [Container(width: 12, height: 12, color: Colors.purple), SizedBox(width: 6), Text("10", style: TextStyle(fontSize: 14))]),
                        SizedBox(width: 14),
                        Row(children: [Container(width: 12, height: 12, color: Colors.green), SizedBox(width: 6), Text("30", style: TextStyle(fontSize: 14))]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
