class NewsItem {
  final String title;
  final String link;
  final String summary;
  final String press;
  final String date;
  final String imageUrl;

  NewsItem({
    required this.title,
    required this.link,
    required this.summary,
    required this.press,
    required this.date,
    required this.imageUrl,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'],
      link: json['link'],
      summary: json['summary'],
      press: json['press'],
      date: json['date'],
      imageUrl: json['imageUrl'],
    );
  }
}
