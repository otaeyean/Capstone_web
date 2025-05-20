import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class RealTimeLineChart extends StatelessWidget {
  final List<double> prices;
  const RealTimeLineChart({required this.prices});

  @override
  Widget build(BuildContext context) {
    if (prices.length < 2) {
      return const Center(
        child: Text(
          "실시간 데이터를 기다리는 중...",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final List<Map<String, num>> chartData = List.generate(prices.length, (i) {
      return {'x': i, 'y': prices[i]};
    });

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Chart(
        data: chartData,
        variables: {
          'x': Variable(
            accessor: (Map<String, num> map) => map['x']!,
            scale: LinearScale(min: 0),
          ),
          'y': Variable(
            accessor: (Map<String, num> map) => map['y']!,
            scale: LinearScale(),
          ),
        },
        marks: [
          LineMark(
            position: Varset('x') * Varset('y'),
            color: ColorEncode(value: Colors.cyanAccent),
            shape: ShapeEncode(value: BasicLineShape()),
          ),
        ],
        axes: [
          Defaults.horizontalAxis,
          Defaults.verticalAxis,
        ],
      ),
    );
  }
}
