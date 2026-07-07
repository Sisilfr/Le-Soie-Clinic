import 'package:flutter/foundation.dart';
import '../services/auth_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthStorageService _storageService = AuthStorageService();

  bool _isLoggedIn = false;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  Future<void> checkAutoLogin() async {
    _isLoading = true;
    notifyListeners();
    try {
      _isLoggedIn = await _storageService.getLoginStatus();
    } catch (_) {
      _isLoggedIn = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simple validation (non-empty & basic email format)
    if (email.isNotEmpty && password.isNotEmpty && email.contains('@')) {
      await _storageService.saveLoginStatus(true);
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
      _isLoading = false;
      notifyListeners();
      throw Exception('Format email tidak valid atau password kosong');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _storageService.clear();
    _isLoggedIn = false;
    _isLoading = false;
    notifyListeners();
  }
}
