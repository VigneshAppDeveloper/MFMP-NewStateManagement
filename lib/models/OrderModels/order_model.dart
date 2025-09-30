class OrderModel {
  final String transId;
  final String orderId;
  final String restaurantName;
  final String pickupPoint;
  final String pickupDate;
  final String pickupTime;
  final String bookingDate;
  final String bookingTime;
  final String itemDetails;
  final double total;
  final String status;
  final double rating;
  final String ownerName;
  final String ownerPhone;

  OrderModel({
    required this.transId,
    required this.orderId,
    required this.restaurantName,
    required this.pickupPoint,
    required this.pickupDate,
    required this.pickupTime,
    required this.bookingDate,
    required this.bookingTime,
    required this.itemDetails,
    required this.total,
    required this.status,
    required this.rating,
    required this.ownerName,
    required this.ownerPhone,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      transId: json['trans_id'] ?? '',
      orderId: json['order_id'] ?? '',
      restaurantName: json['restaurant_name'] ?? '',
      pickupPoint: json['pickup_point'] ?? '',
      pickupDate: json['pickup_date'] ?? '',
      pickupTime: json['pickup_time'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      bookingTime: json['booking_time'] ?? '',
      itemDetails: json['item_details'] ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ownerName: json['owner_name'] ?? '',
      ownerPhone: json['owner_phone'] ?? '',
    );
  }
}
