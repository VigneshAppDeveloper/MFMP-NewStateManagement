class PaymentStatusResponse {
  final String? paymentStatus;

  PaymentStatusResponse({this.paymentStatus});

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return PaymentStatusResponse(
      paymentStatus: data != null ? data['payment_status']?.toString() : null,
    );
  }

  bool get isSuccess => paymentStatus?.toLowerCase() == 'success';
  bool get isFailed => paymentStatus?.toLowerCase() == 'failed';
  bool get isPending => paymentStatus == null || paymentStatus!.isEmpty;
}
