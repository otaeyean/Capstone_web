import 'package:flutter/material.dart';
import 'package:stockapp/server/investment/recommend/recommend_list_server.dart';
import 'package:stockapp/data/category_icon_map.dart';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart'; // 애니메이션 효과를 위한 패키지 추가

class RecommendationTab extends StatefulWidget {
  @override
  _RecommendationTabState createState() => _RecommendationTabState();
}

class _RecommendationTabState extends State<RecommendationTab> {
  List<String> todayCategories = [];
  List<String> allCategories = [];
  final RecommendListServer apiService = RecommendListServer();

  final List<Color> iconColors = [
    Color.fromARGB(255, 133, 216, 170),

  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchAllCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      List<String> categories = await apiService.fetchCategories();
      setState(() {
        todayCategories = categories;
      });
    } catch (e) {
      print('Error fetching today categories: $e');
    }
  }

  Future<void> _fetchAllCategories() async {
    try {
      List<String> categories = await apiService.fetchAllCategories();
      setState(() {
        allCategories = categories;
      });
    } catch (e) {
      print('Error fetching all categories: $e');
    }
  }

  Color getRandomColor() {
    final rand = Random();
    return iconColors[rand.nextInt(iconColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: 1),
          SizedBox(height: 8),
          allCategories.isEmpty
              ? Center(child: CircularProgressIndicator())
              : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    String categoryName = allCategories[index];
                    IconData? categoryIcon = categoryIconMap[categoryName] ?? Icons.category;
                    Color bgColor = getRandomColor();

                    return GestureDetector(
                      onTap: () {
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 12),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: bgColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  categoryIcon,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                categoryName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 12),
                          ],
                        ),
                      ).animate().scale(
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
