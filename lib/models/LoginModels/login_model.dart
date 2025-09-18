class LoginModel {
  final bool success;
  final String message;
  final String? token;

  LoginModel({required this.success, required this.message, this.token});

  factory LoginModel.fromMap(Map<String, dynamic> json) {
    return LoginModel(
     success: json['status'] ?? json['success'] ?? false,

      message: json['message'] ?? '',
      token: json['access_token'],
    );
  }
}
