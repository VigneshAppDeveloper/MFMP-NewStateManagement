class RegisterResponseModel {
  final bool success;
  final String message;
  final String? token;

  RegisterResponseModel({
    required this.success,
    required this.message,
    this.token,
  });

  factory RegisterResponseModel.fromMap(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['status'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
    );
  }
}
