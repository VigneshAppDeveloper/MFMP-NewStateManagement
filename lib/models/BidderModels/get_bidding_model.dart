class BiddingModel {
  final String menuId;
  final String timerId;
  final String highestPrice;
  final String name; // highest bidder name
  final String? basePrice; // ✅ add this

  BiddingModel({
    required this.menuId,
    required this.timerId,
    required this.highestPrice,
    required this.name,
    this.basePrice, // ✅ optional
  });

  factory BiddingModel.fromJson(Map<String, dynamic> json) {
    return BiddingModel(
      menuId: json['menu_id']?.toString() ?? '',
      timerId: json['timer_id']?.toString() ?? '',
      highestPrice: json['highest_price']?.toString() ?? '0',
      name: json['name']?.toString() ?? '',
      basePrice: json['base_price']?.toString(), // ✅ handle if backend sends it
    );
  }

  static List<BiddingModel> listFromJson(List<dynamic> list) {
    return list.map((e) => BiddingModel.fromJson(e)).toList();
  }
}

