class BidderCountModel {
  final int bidderCount;
  final String? message;
  final bool success;

  BidderCountModel({
    required this.bidderCount,
    this.message,
    required this.success,
  });

  factory BidderCountModel.fromJson(Map<String, dynamic> json) {
    return BidderCountModel(
      bidderCount: int.tryParse(json['data']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString(),
      success: json['success'] ?? false,
    );
  }
}
