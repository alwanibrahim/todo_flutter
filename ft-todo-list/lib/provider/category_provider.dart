import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/models/todo_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['API_URL'] ??
        'http://192.168.43.9:8000', // Sesuaikan base URL
  ));

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken(); // Ambil token
      if (token == null) throw Exception("Token tidak ditemukan");

      final response = await _dio.get(
        '/api/categories',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      _categories = (response.data as List)
          .map((json) => Category.fromJson(json))
          .toList();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal mengambil kategori: $e";
      print("Error fetching categories: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final response = await _dio.post(
        '/api/categories',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: {'name': name}, // Data yang dikirim ke API
      );

      // Jika berhasil, tambahkan kategori ke daftar lokal
      final newCategory = Category.fromJson(response.data);
      _categories.add(newCategory);

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Gagal menambah kategori: $e";
      print("Error adding category: $_errorMessage");
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
