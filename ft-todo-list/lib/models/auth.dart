class LoginResponse {
  final String token;
  final String message;

  LoginResponse({required this.token, required this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '', // Beri nilai default jika null
      message: json['message'] ?? '', // Beri nilai default jika null
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String? token; // Token bisa null jika tidak disertakan dalam respons

  User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'], // Token diambil dari luar objek user
    );
  }
}
