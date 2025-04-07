import 'package:flutter/material.dart';

class StockChartControls extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodSelected;
  final Function(bool) onZoom;

  const StockChartControls({
    Key? key,
    required this.selectedPeriod,
    required this.onPeriodSelected,
    required this.onZoom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> periods = ["1m", "D", "W", "M"];
    final Map<String, String> periodLabels = {
      "1m": "1분",
      "D": "일",
      "W": "주",
      "M": "월"
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         ToggleButtons(
  isSelected: periods.map((period) => period == selectedPeriod).toList(),
  onPressed: (int index) {
    onPeriodSelected(periods[index]);
  },
  borderRadius: BorderRadius.circular(5),
  selectedColor: Colors.white,
  color: Colors.black,
  fillColor: const Color(0xFF67CA98), // 선택된 버튼 초록색
  hoverColor: const Color(0xFFB5E8D0), // ✅ 마우스 hover 시 연한 초록색
  borderColor: Colors.grey,
  selectedBorderColor: const Color(0xFF67CA98),
  constraints: const BoxConstraints(minWidth: 60, minHeight: 35),
  children: periods.map((period) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Text(
        periodLabels[period] ?? period,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }).toList(),
),

          SizedBox(width: 20),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.zoom_out),
                onPressed: () => onZoom(false),
              ),
              IconButton(
                icon: Icon(Icons.zoom_in),
                onPressed: () => onZoom(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
