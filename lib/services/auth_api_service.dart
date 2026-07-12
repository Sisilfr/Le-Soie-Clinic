import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  static const String baseUrl = 'https://syahrulawaludin.my.id/api/v1';

  /// Authenticate user via Login endpoint
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        String errorMessage = 'Login gagal. Silakan coba lagi.';
        if (data is Map) {
          if (data['error'] != null && data['error']['message'] != null) {
            errorMessage = data['error']['message'];
          } else if (data['message'] != null) {
            errorMessage = data['message'];
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  /// Register new user via Register endpoint
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        String errorMessage = 'Pendaftaran gagal. Silakan coba lagi.';
        if (data is Map) {
          if (data['error'] != null && data['error']['message'] != null) {
            errorMessage = data['error']['message'];
          } else if (data['message'] != null) {
            errorMessage = data['message'];
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}
