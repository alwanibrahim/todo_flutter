import 'package:flutter/material.dart';
import 'package:image/api/api_auth.dart';
import 'package:image/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLogin = false;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLogin => _isLogin;

  // 🔹 Constructor untuk memeriksa login saat pertama kali aplikasi dibuka
  AuthProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    print('DEBUG: Token di SharedPreferences -> $token'); // ✅ Debugging

    if (token != null && token.isNotEmpty) {
      _isLogin = true;
    } else {
      _isLogin = false;
    }
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await ApiAuth().register(name, email, password);
      if (user.token!.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Error during registration: $e');
    }
  }

  // ✅ Tambahkan Logout Function
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _isLogin = false; // Update login state on logout
    _user = null;
    notifyListeners();
  }

  void loginSucces() {
    _isLogin = true;
    notifyListeners();
  }
}
