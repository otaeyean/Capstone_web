import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'news_model.dart';
import '../server/SharedPreferences/user_nickname.dart';
import '../server/home/news_api.dart';
import 'package:html_unescape/html_unescape.dart';

class UserNewsScreen extends StatefulWidget {
  const UserNewsScreen({super.key});

  @override
  State<UserNewsScreen> createState() => _UserNewsScreenState();
}

class _UserNewsScreenState extends State<UserNewsScreen> {
  List<NewsItem> _newsList = [];
  int _currentPage = 0;
  late Timer _timer;
  String? _userId;
  late PageController _pageController;

  final unescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _pageController = PageController(viewportFraction: 1);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_newsList.isNotEmpty) {
        setState(() {
          _currentPage = (_currentPage + 1) % (_newsList.length ~/ 3);
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadUserId() async {
    final id = await AuthService.getUserId();
    if (id != null) {
      setState(() {
        _userId = id;
      });
      fetchNews(id);
    } else {
      print("🚨 userId(nickname)를 불러오지 못했습니다.");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchNews(String userId) async {
    try {
      final newsList = await NewsApi.fetchUserNews(userId);
      setState(() {
        _newsList = newsList;
      });
    } catch (e) {
      print("❌ 뉴스 불러오기 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null || _newsList.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Center(child: Text(
            "관련 뉴스를 불러오고 있습니다...",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          )),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       const Padding(
  padding: EdgeInsets.all(16.0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center, // ✅ 수직 가운데 정렬
    children: [
      Icon(
        Icons.auto_awesome, // ✅ 예시 아이콘 (귀엽고 통용 가능)
        color: Color(0xFF0F1E46),
        size: 24,
      ),
      SizedBox(width: 8),
      Expanded(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '투자 종목 관련 ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'MinSans',
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: '뉴스',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'MinSans',
                  color: Colors.green,
                ),
              ),
              TextSpan(
                text: ' 확인',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'MinSans',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

        SizedBox(
          height: 380,
          child: PageView.builder(
            controller: _pageController,
            itemCount: (_newsList.length ~/ 3),
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
          itemBuilder: (context, index) {
            final news = _newsList.skip(index * 3).take(3).toList();
            return Column(
              children: news.map((newsItem) {
                return GestureDetector(
                  onTap: () => launchUrl(Uri.parse(newsItem.link), mode: LaunchMode.externalApplication),
                  child: Card(
                    color: const Color(0xFFF7F9FC),
                    margin: const EdgeInsets.all(8),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                          child: newsItem.imageUrl != null
                              ? Image.network(
                                  newsItem.imageUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported, size: 50),
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  unescape.convert(newsItem.title),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  unescape.convert(newsItem.summary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${newsItem.press} | ${newsItem.date}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          ),
        ),
      ],
    );
  }
}
