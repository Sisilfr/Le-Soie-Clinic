import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/article_service.dart';

class ArticleProvider extends ChangeNotifier {
  final ArticleService _service = ArticleService();

  List<Article> _articles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchArticles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _articles = await _service.fetchArticles();
    } catch (e) {
      _errorMessage = e.toString();
      _articles = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
