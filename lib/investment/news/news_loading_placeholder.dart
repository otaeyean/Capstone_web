import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NewsLoadingPlaceholder extends StatelessWidget {
  const NewsLoadingPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(7, (index) => _buildShimmerItem()),
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: Duration(seconds: 2),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
        child: ListTile(
          contentPadding: EdgeInsets.all(10),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          title: Container(
            width: double.infinity,
            height: 12,
            color: Colors.white,
          ),
          subtitle: Container(
            width: double.infinity,
            height: 10,
            margin: EdgeInsets.only(top: 5),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
