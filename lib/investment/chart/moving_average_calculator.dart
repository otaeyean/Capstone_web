import 'package:stockapp/investment/chart/stock_price.dart';

List<StockPrice> calculateMovingAverage(List<StockPrice> data, int period) {
  List<StockPrice> movingAverageData = [];

  for (int i = 0; i < data.length; i++) {
    double sum = 0;
    int count = 0;

    for (int j = 0; j < period && i - j >= 0; j++) {
      sum += data[i - j].close;
      count++;
    }

    double average = sum / count;
    movingAverageData.add(StockPrice(
      date: data[i].date,
      open: average,
      high: average,
      low: average,
      close: average,
      volume: 0,
    ));
  }

  return movingAverageData;
}
