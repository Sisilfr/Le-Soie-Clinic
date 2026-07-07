import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductApiService _apiService = ProductApiService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _apiService.fetchSkincareProducts();
    } catch (e) {
      _errorMessage = e.toString();
      _products = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
