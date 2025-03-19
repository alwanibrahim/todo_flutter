import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/models/todo_model.dart';

class TodoApi {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['API_URL'] ?? 'http://192.168.43.9:8000',
    headers: {"Accept": "application/json"},
  ));

  Future<List<Todo>> fetchTodos() async {
    try {
      // Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("Token yang digunakan: $token");

      // Validasi token
      if (token == null || token.isEmpty) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      // Set header Authorization
      _dio.options.headers["Authorization"] = "Bearer $token";

      print("Mengambil data dari API...");

      // Lakukan request ke API
      final response = await _dio.get('/api/todos');
      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      // Validasi response
      if (response.statusCode == 200) {
        // Pastikan response.data adalah List
        if (response.data is! List) {
          throw Exception("Format response tidak valid: ${response.data}");
        }

        // Konversi response.data ke List<Todo>
        List<dynamic> data = response.data;
        return data.map((json) => Todo.fromJson(json)).toList();
      } else {
        throw Exception(
            'Gagal mengambil data To-Do, status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Tangani error dari Dio (misalnya, koneksi bermasalah)
      print("DioError: ${e.message}");
      if (e.response != null) {
        print("Response error: ${e.response?.data}");
      }
      throw Exception("Gagal terhubung ke server: ${e.message}");
    } catch (e) {
      // Tangani error umum
      print("Error umum terjadi: $e");
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  Future<Todo> createTodo(Map<String, dynamic> todoData) async {
    try {
      // Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("Token yang digunakan: $token");

      // Validasi token
      if (token == null || token.isEmpty) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      // Set header Authorization
      _dio.options.headers["Authorization"] = "Bearer $token";

      print("Mengirim data ke API...");

      // Lakukan request POST ke API
      final response = await _dio.post('/api/todos', data: todoData);
      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      // Validasi response
      if (response.statusCode == 201) {
        // Pastikan response.data adalah Map<String, dynamic>
        if (response.data is! Map<String, dynamic>) {
          throw Exception("Format response tidak valid: ${response.data}");
        }

        // Jika response memiliki key 'data', gunakan itu
        final responseData = response.data['data'] ?? response.data;

        // Konversi responseData ke Todo
        return Todo.fromJson(responseData);
      } else {
        throw Exception('Gagal membuat To-Do, status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Tangani error dari Dio
      print("DioError: ${e.message}");
      if (e.response != null) {
        print("Response error: ${e.response?.data}");
      }
      throw Exception("Gagal terhubung ke server: ${e.message}");
    } catch (e) {
      // Tangani error umum
      print("Error umum terjadi: $e");
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  Future<Todo> updateTodo(int id, Map<String, dynamic> todoData) async {
    try {
      // Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("Token yang digunakan: $token");

      // Validasi token
      if (token == null || token.isEmpty) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      // Set header Authorization
      _dio.options.headers["Authorization"] = "Bearer $token";

      print("Mengirim data update ke API...");

      // Lakukan request PUT ke API
      final response = await _dio.put('/api/todos/$id', data: todoData);
      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      // Validasi response
      if (response.statusCode == 200) {
        // Pastikan response.data adalah Map<String, dynamic>
        if (response.data is! Map<String, dynamic>) {
          throw Exception("Format response tidak valid: ${response.data}");
        }

        // Konversi response ke Todo
        return Todo.fromJson(response.data);
      } else {
        throw Exception(
            'Gagal mengupdate To-Do, status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Tangani error dari Dio
      print("DioError: ${e.message}");
      if (e.response != null) {
        print("Response error: ${e.response?.data}");
      }
      throw Exception("Gagal terhubung ke server: ${e.message}");
    } catch (e) {
      // Tangani error umum
      print("Error umum terjadi: $e");
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      // Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("Token yang digunakan: $token");

      // Validasi token
      if (token == null || token.isEmpty) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      // Set header Authorization
      _dio.options.headers["Authorization"] = "Bearer $token";

      print("Menghapus data To-Do dengan ID: $id...");

      // Lakukan request DELETE ke API
      final response = await _dio.delete('/api/todos/$id');
      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      // Validasi response
      if (response.statusCode == 200 || response.statusCode == 204) {
        print("To-Do berhasil dihapus.");
      } else {
        throw Exception(
            "Gagal menghapus To-Do, status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      // Tangani error dari Dio
      print("DioError: ${e.message}");
      if (e.response != null) {
        print("Response error: ${e.response?.data}");
      }
      throw Exception("Gagal terhubung ke server: ${e.message}");
    } catch (e) {
      // Tangani error umum
      print("Error umum terjadi: $e");
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      // Ambil token dari SharedPreferences atau Provider
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await _dio.get(
        '/api/categories',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Tambahkan token ke header
            'Accept': 'application/json',
          },
        ),
      );

      print("Response kategori dari API: ${response.data}");

      List<Category> categories = (response.data as List)
          .map((json) => Category.fromJson(json))
          .toList();

      return categories;
    } catch (e) {
      print("Error getCategories(): $e");
      throw Exception("Gagal mengambil kategori");
    }
  }
}
