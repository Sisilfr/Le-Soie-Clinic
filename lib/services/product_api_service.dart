import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductApiService {
  Future<List<Product>> fetchSkincareProducts() async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products/category/skincare'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> productList = data['products'] ?? [];
      return productList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
