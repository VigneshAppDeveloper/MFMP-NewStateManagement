class OrderBiddingResponse {
  final String message;
  final bool success;
  final String? orderId;

  OrderBiddingResponse({
    required this.message,
    required this.success,
    this.orderId,
  });

  factory OrderBiddingResponse.fromJson(Map<String, dynamic> json) {
    return OrderBiddingResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      orderId: json['data']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'success': success,
        'data': orderId,
      };
}