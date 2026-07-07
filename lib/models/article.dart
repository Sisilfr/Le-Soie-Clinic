class Article {
  final int id;
  final String title;
  final String category; // 'Kandungan', 'Kesehatan Kulit', 'Kebiasaan Sehat'
  final String summary;
  final String content;
  final String imageUrl;

  Article({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.imageUrl,
  });
}
