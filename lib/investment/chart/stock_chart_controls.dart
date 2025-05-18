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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 📌 기간 선택 버튼
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF2F4F5),
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: periods.map((period) {
                final isSelected = period == selectedPeriod;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () => onPeriodSelected(period),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF67CA98) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        periodLabels[period]!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Color(0xFF03314B),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 🔍 줌 아이콘 버튼
          Row(
            children: [
                _zoomButton(Icons.zoom_in, () => onZoom(true)),
              const SizedBox(width: 8),
                _zoomButton(Icons.zoom_out, () => onZoom(false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF2F4F5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Color(0xFF03314B)),
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }
}
