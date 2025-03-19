import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiAuth {
  final String baseUrl = 'http://192.168.43.9:8000';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['API_URL'] ?? '',
    headers: {"Accept": "application/json"},
  ));

  Future<LoginResponse?> getToken(String email, String password) async {
    try {
      var response = await _dio.post(
        '$baseUrl/api/login',
        data: {'email': email, 'password': password},
      );

      print(
          "Response Data: ${response.data}"); // Debugging: Log the response data

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final loginResponse = LoginResponse.fromJson(response.data);
        print(
            "Token received: ${loginResponse.token}"); // Debugging: Log the token received

        if (loginResponse.token.isNotEmpty) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', loginResponse.token); // Simpan token

          print("Token disimpan: ${loginResponse.token}");
          return loginResponse;
        }
      }
      return null;
    } on DioException catch (e) {
      print(
          "DioError di getToken: ${e.response?.data ?? e.message}. Please check your credentials.");
      return null;
    } catch (e) {
      print("Error di getToken: $e");
      return null;
    }
  }

  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
        options: Options(headers: {
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 201) {
        // Pastikan respons memiliki struktur yang sesuai
        if (response.data['user'] != null && response.data['token'] != null) {
          final user = User.fromJson({
            ...response.data['user'], // Data user
            'token': response.data['token'], // Token dari luar objek user
          });

          // Simpan token ke SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', user.token!);

          print("Token received: ${user.token}");
          return user;
        } else {
          throw Exception('Invalid response structure: ${response.data}');
        }
      } else {
        throw Exception('Error during registration: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Error during registration: ${e.response?.data ?? e.message}');
    }
  }

  Future<dynamic> getUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token'); // Ambil token

      if (token == null || token.isEmpty) {
        print("Token tidak ditemukan.");
        return null;
      }

      var response = await _dio.get(
        '$baseUrl/api/user',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print("User Response: ${response.data}");

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      print("DioError di getUser: ${e.response?.data ?? e.message}");
      return null;
    } catch (e) {
      print("Error di getUser: $e");
      return null;
    }
  }
}
