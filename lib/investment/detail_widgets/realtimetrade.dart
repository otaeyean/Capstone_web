import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stockapp/investment/detail_widgets/realtime_line_chart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class RealTimePriceChart extends StatefulWidget {
  final String stockCode;
  const RealTimePriceChart({required this.stockCode});

  @override
  _RealTimePriceChartState createState() => _RealTimePriceChartState();
}

class _RealTimePriceChartState extends State<RealTimePriceChart> {
  late IOWebSocketChannel channel;
  List<double> prices = [];

  @override
  void initState() {
    super.initState();

    channel = IOWebSocketChannel.connect('ws://withyou.me:8080/ws-client');

    final subscribeMessage = jsonEncode({
      "action": "subscribe",
      "stockCode": widget.stockCode,
    });
    channel.sink.add(subscribeMessage);

    channel.stream.listen((message) {
      try {
        final data = jsonDecode(message);
        if (data['stockCode'] == widget.stockCode) {
          double? price = double.tryParse(data['currentPrice'].toString());
          if (price != null) {
            setState(() {
              prices.add(price);
              if (prices.length > 50) {
                prices.removeAt(0);
              }
            });
          }
        }
      } catch (e) {
        print("❌ 파싱 오류: $e");
      }
    });
  }

  @override
  void dispose() {
    final unsubscribeMessage = jsonEncode({
      "action": "unsubscribe",
      "stockCode": widget.stockCode,
    });
    channel.sink.add(unsubscribeMessage);
    channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (prices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "📈 실시간 체결가: ${prices.last.toStringAsFixed(0)}원",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1B2A),
              ),
            ),
          ),
        Expanded(
          child: RealTimeLineChart(prices: prices),
        ),
      ],
    );
  }
}
