import 'package:flutter/material.dart';
import 'package:stockapp/category/company_list_page.dart';
import 'package:stockapp/server/home/recommended_server.dart';
import 'package:stockapp/data/category_icon_map.dart';


class RecommendedStocks extends StatefulWidget {
  const RecommendedStocks({Key? key});

  @override
  State<RecommendedStocks> createState() => _RecommendedStocksState();
}

class _RecommendedStocksState extends State<RecommendedStocks> {
  List<String> recommendedCategories = [];
  List<String> unrecommendedCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final result = await RecommendedService.fetchRecommendedCategories();

      final half = result.length ~/ 2;
      setState(() {
        recommendedCategories = result.sublist(0, half);
        unrecommendedCategories = result.sublist(half);
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildCategoryItem(String name) {
    final icon = categoryIconMap[name] ?? Icons.category;
    final imagePath = 'assets/images/$name.png';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompanyListPage(category: name),
          ),
        );
      },
      child: Container(
        width: 137,
        height: 140,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color.fromARGB(255, 182, 181, 181),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(icon, size: 40, color: Colors.black);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'MinSans',
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStyledTitle(String title) {
    IconData icon;
    String greenPart;
    String before = '';
    String after = '';

    if (title.contains("뜨고 있는")) {
      icon = Icons.bookmark;
      greenPart = "뜨고 있는";
    } else if (title.contains("주의가 필요")) {
      icon = Icons.bookmark;
      greenPart = "주의가 필요";
    } else {
      icon = Icons.category;
      return Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              fontFamily: 'MinSans',
              color: Colors.black,
            ),
          ),
        ],
      );
    }

    final parts = title.split(greenPart);
    before = parts[0];
    after = parts.length > 1 ? parts[1] : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
        Icons.bookmark, // 📰 뉴스 느낌의 아이콘
        color: const Color.fromARGB(255, 15, 30, 70),
        size: 24,
      ),
        const SizedBox(width: 6),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: before,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'MinSans',
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: greenPart,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'MinSans',
                  color: Colors.green,
                ),
              ),
              TextSpan(
                text: after,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'MinSans',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCategoryGroup(String title, List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildStyledTitle(title),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              categories.length,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: buildCategoryItem(categories[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLoadingItem() {
    return Container(
      width: 137,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
    );
  }

  Widget buildLoadingGroup(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildStyledTitle(title),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: buildLoadingItem(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          isLoading
              ? buildLoadingGroup("현재 뜨고 있는 카테고리")
              : buildCategoryGroup("현재 뜨고 있는 카테고리", recommendedCategories),
          const SizedBox(height: 20),
          isLoading
              ? buildLoadingGroup("현재 주의가 필요한 카테고리")
              : buildCategoryGroup("현재 주의가 필요한 카테고리", unrecommendedCategories),
        ],
      ),
    );
  }
}
