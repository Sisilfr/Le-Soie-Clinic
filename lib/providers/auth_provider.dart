import 'package:flutter/foundation.dart';
import '../services/auth_storage_service.dart';
import '../services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthStorageService _storageService = AuthStorageService();
  final AuthApiService _apiService = AuthApiService();

  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _userName;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get userName => _userName;

  Future<void> checkAutoLogin() async {
    _isLoading = true;
    notifyListeners();
    try {
      _isLoggedIn = await _storageService.getLoginStatus();
      if (_isLoggedIn) {
        _userName = await _storageService.getUserName();
      }
    } catch (_) {
      _isLoggedIn = false;
      _userName = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email dan password tidak boleh kosong');
      }
      if (!email.contains('@')) {
        throw Exception('Format email tidak valid');
      }
      
      // Call Auth API
      final response = await _apiService.login(email, password);
      final name = response['data']?['name'] ?? 'User';
      
      await _storageService.saveLoginStatus(true);
      await _storageService.saveUserName(name);
      _isLoggedIn = true;
      _userName = name;
    } catch (e) {
      _isLoggedIn = false;
      _userName = null;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('Semua kolom harus diisi');
      }
      if (!email.contains('@')) {
        throw Exception('Format email tidak valid');
      }
      
      // Call Auth API for registration
      final response = await _apiService.register(name, email, password);
      final registeredName = response['data']?['name'] ?? name;
      
      // Automatically log in the user on successful registration
      await _storageService.saveLoginStatus(true);
      await _storageService.saveUserName(registeredName);
      _isLoggedIn = true;
      _userName = registeredName;
    } catch (e) {
      _isLoggedIn = false;
      _userName = null;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _storageService.clear();
    _isLoggedIn = false;
    _userName = null;
    _isLoading = false;
    notifyListeners();
  }
}
