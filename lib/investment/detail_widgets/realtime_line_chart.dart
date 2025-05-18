import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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

    double min = prices.reduce((a, b) => a < b ? a : b);
    double max = prices.reduce((a, b) => a > b ? a : b);
    double center = (min + max) / 2;
    double minY = center - 500;
    double maxY = center + 500;
    double yInterval = ((maxY - minY) / 5).roundToDouble();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: yInterval,
                reservedSize: 48,
                getTitlesWidget: (value, _) => Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white10,
              strokeWidth: 0.5,
            ),
            getDrawingVerticalLine: (_) => FlLine(
              color: Colors.white10,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                prices.length,
                (i) => FlSpot(i.toDouble(), prices[i]),
              ),
              isCurved: true,
              barWidth: 2.5,
              gradient: const LinearGradient(
                colors: [Color(0xFF4FC3F7), Color(0xFF4FC3F7)],
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF81D4FA).withOpacity(0.25),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
