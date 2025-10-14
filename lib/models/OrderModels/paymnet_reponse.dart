class PaymentStatusResponse {
  final String? status;

  PaymentStatusResponse({this.status});

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResponse(
      status: json['result']?['payment_status']?.toString(),
    );
  }

  bool get isSuccess => status?.toLowerCase() == 'success';
  bool get isFailed => status?.toLowerCase() == 'failed';
  bool get isPending => status == null || status!.isEmpty;
}