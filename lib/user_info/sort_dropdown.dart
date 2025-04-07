import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_model.dart';

class SortDropdown extends StatefulWidget {
  final List<UserStockModel> stocks;
  final Function(List<UserStockModel>) onSortChanged;

  SortDropdown({required this.stocks, required this.onSortChanged});

  @override
  _SortDropdownState createState() => _SortDropdownState();
}

class _SortDropdownState extends State<SortDropdown> {
  String selectedSort = "수익률 순";

  void _sortStocks(String sortType) {
    setState(() {
      selectedSort = sortType;
    });

    List<UserStockModel> sorted = List.from(widget.stocks);

    if (sortType == "수익률 순") {
      sorted.sort((a, b) => (b.profitRate ?? 0).compareTo(a.profitRate ?? 0));
    } else if (sortType == "보유 자산 순") {
      sorted.sort((a, b) => (b.totalValue ?? 0).compareTo(a.totalValue ?? 0));
    }

    widget.onSortChanged(sorted);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> sortOptions = ["수익률 순", "보유 자산 순"];
    final Color activeColor = Color(0xFF03314B);
    final Color inactiveColor = Colors.grey;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: sortOptions.map((option) {
        final bool isSelected = selectedSort == option;
        return GestureDetector(
          onTap: () => _sortStocks(option),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
