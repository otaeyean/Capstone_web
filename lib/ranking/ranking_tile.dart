import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RankingTile extends StatelessWidget {
  final int rank;
  final String userId;
  final double profit;

  RankingTile({
    required this.rank,
    required this.userId,
    required this.profit,
  });

  Color getBackgroundColor() {
    switch (rank) {
      case 1:
        return Color(0xFFFFF4D2); // 금색
      case 2:
        return Color(0xFFEDEDED); // 은색
      case 3:
        return Color(0xFFEFE0D0); // 동색
      default:
        return Colors.white;
    }
  }

  Widget getRankBadge() {
    final badgeStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    if (rank == 1) {
      return Icon(Icons.emoji_events, color: Colors.amber[700], size: 30);
    } else if (rank == 2) {
      return Icon(Icons.emoji_events, color: Colors.grey[500], size: 28);
    } else if (rank == 3) {
      return Icon(Icons.emoji_events, color: Colors.brown[300], size: 26);
    } else {
      return Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0xFFD0EBE1), 
          shape: BoxShape.circle,
        ),
        child: Text('$rank', style: badgeStyle.copyWith(fontSize: 14)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentFormat = NumberFormat("###,###.##", "en_US");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          getRankBadge(),
          SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  userId,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1F3B), // 딥 네이비
                  ),
                ),
                Text(
                  '${percentFormat.format(profit)}%',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: profit > 0
                        ? Colors.redAccent
                        : (profit < 0 ? Colors.blueAccent : Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}