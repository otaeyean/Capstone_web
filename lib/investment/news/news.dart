import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stockapp/server/investment/news/news_server.dart';
import 'package:stockapp/server/investment/news/news_prediction_server.dart';
import './news_prediction.dart';
import './news_loading_placeholder.dart'; 

class NewsScreen extends StatefulWidget {
  final String stockName;

  const NewsScreen({required this.stockName, Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<Map<String, dynamic>>> futureNews;
  String? predictionText;

  @override
  void initState() {
    super.initState();
    futureNews = NewsService.fetchNews(widget.stockName);
  }

  void fetchPredictionData() async {
    final result = await NewsPredictionService.fetchPrediction(widget.stockName);
    setState(() {
      predictionText = result;
    });
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureNews,
      builder: (context, newsSnapshot) {
        if (newsSnapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.all(10),
            child: NewsLoadingPlaceholder(), 
          );
        } else if (newsSnapshot.hasError ||
            !newsSnapshot.hasData ||
            newsSnapshot.data!.isEmpty) {
          return Center(child: Text('관련 뉴스가 없습니다.'));
        }

        if (predictionText == null) {
          fetchPredictionData();
        }

        List<Map<String, dynamic>> articles = newsSnapshot.data!;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (predictionText != null)
                  NewsPredictionWidget(predictionText: predictionText!), 

                ...articles.map((article) {
                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: article['imageUrl'] != null && article['imageUrl'].isNotEmpty
                          ? Image.network(
                              article['imageUrl'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.white,
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: Colors.white,
                            ),
                      title: Text(article['title'], style: TextStyle(fontFamily: 'Nanum',fontSize: 17,fontWeight: FontWeight.w900)),
                      subtitle: Text(article['summary'] ?? '',  style: TextStyle(fontFamily: 'Nanum',fontSize: 17,fontWeight: FontWeight.w500),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () => _launchURL(article['link']),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}