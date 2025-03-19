import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/models/todo_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabelProvider with ChangeNotifier {
  List<Label> _labels = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Label> get labels => _labels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final Dio _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_URL'] ??
          'http://192.168.43.9:8000')); // Sesuaikan base URL

  Future<void> fetchLabels() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken(); // Ambil token
      if (token == null) throw Exception("Token tidak ditemukan");

      final response = await _dio.get(
        '/api/labels',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      _labels =
          (response.data as List).map((json) => Label.fromJson(json)).toList();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal mengambil kategori: $e";
      print("Error fetching categories: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
