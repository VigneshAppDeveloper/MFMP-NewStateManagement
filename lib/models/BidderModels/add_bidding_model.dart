class BiddingRequestModel {
  final String userId;
  final String franchiseId;
  final String timerId;
  final String menuCategoryId;
  final String name;
  final String menuCategoryName;
  final String description;
  final double currentPrice;

  BiddingRequestModel({
    required this.userId,
    required this.franchiseId,
    required this.timerId,
    required this.menuCategoryId,
    required this.name,
    required this.menuCategoryName,
    required this.description,
    required this.currentPrice,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'franchise_id': franchiseId,
        'timer_id': timerId,
        'menu_category_id': menuCategoryId,
        'name': name,
        'menu_category_name': menuCategoryName,
        'description': description,
        'current_price': currentPrice.toStringAsFixed(2),
      };
}
