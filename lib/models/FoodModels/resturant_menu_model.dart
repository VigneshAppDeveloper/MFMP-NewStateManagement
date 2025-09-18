enum FoodType { veg, nonVeg, halal }

class RestaurantMenuModel {
  final String title;
  final double price;
  final double? oldPrice;
  final double rating;
  final int availableQty;
  final String description;
  final String image;
  final List<FoodType> foodTypes; // ✅ new field

  RestaurantMenuModel({
    required this.title,
    required this.price,
    this.oldPrice,
    required this.rating,
    required this.availableQty,
    required this.description,
    required this.image,
    required this.foodTypes,
  });
}

