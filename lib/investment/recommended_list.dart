import 'package:flutter/material.dart';
import 'package:stockapp/server/investment/recommend/recommend_list_server.dart';
import 'package:stockapp/data/category_icon_map.dart';
import 'dart:math';

class RecommendationTab extends StatefulWidget {
  @override
  _RecommendationTabState createState() => _RecommendationTabState();
}

class _RecommendationTabState extends State<RecommendationTab> {
  List<String> allCategories = [];
  final RecommendListServer apiService = RecommendListServer();

  final List<Color> iconColors = [
    Color.fromARGB(255, 133, 216, 170),
    Color.fromARGB(255, 102, 187, 255),
    Color.fromARGB(255, 255, 204, 128),
    Color.fromARGB(255, 186, 104, 200),
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllCategories();
  }

  Future<void> _fetchAllCategories() async {
    try {
      List<String> categories = await apiService.fetchAllCategories();
      setState(() {
        allCategories = categories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Color getRandomColor() {
    final rand = Random();
    return iconColors[rand.nextInt(iconColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - 20 * 2 - 16) / 2; // padding & spacing 고려

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: 1),
          SizedBox(height: 12),
          allCategories.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Wrap(
                  spacing: 16, // 가로 간격
                  runSpacing: 16, // 세로 간격
                  children: allCategories.map((categoryName) {
                    IconData? categoryIcon =
                        categoryIconMap[categoryName] ?? Icons.category;
                    Color bgColor = getRandomColor();

                    return Container(
                      width: cardWidth,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: bgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              categoryIcon,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
