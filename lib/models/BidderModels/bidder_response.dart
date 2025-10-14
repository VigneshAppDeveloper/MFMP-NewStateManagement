class BidderResponseModel {
  final bool success;
  final String message;
  final dynamic data;

  BidderResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory BidderResponseModel.fromJson(Map<String, dynamic> json) {
    return BidderResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  @override
  String toString() =>
      'BidderResponseModel(success: $success, message: $message, data: $data)';
}