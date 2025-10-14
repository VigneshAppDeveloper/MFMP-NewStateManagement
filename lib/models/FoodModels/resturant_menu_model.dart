import 'package:my_food_my_price/config/app_config.dart';


class RestaurantMenuModel {
  final int id;
  final String franchiseId;
  final String menuType;
  final String? menuCategoryId;
  final String menuName;
  final String dietType;
  final String halal;
  final String description;
  final double basePrice;
  final double currentPrice;
  final String? menuStock;
  final String menuImage;
  final String? scrollingText;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RestaurantMenuModel({
    required this.id,
    required this.franchiseId,
    required this.menuType,
    this.menuCategoryId,
    required this.menuName,
    required this.dietType,
    required this.halal,
    required this.description,
    required this.basePrice,
    required this.currentPrice,
    this.menuStock,
    required this.menuImage,
    this.scrollingText,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RestaurantMenuModel.fromJson(Map<String, dynamic> json) {
    String rawImage = json['menu_image']?.toString() ?? '';
    String fullImage = rawImage.isNotEmpty && !rawImage.startsWith('http')
        ? AppConfig.instance.storageBaseUrl + rawImage
        : rawImage;

    return RestaurantMenuModel(
      id: json['id'] ?? 0,
      franchiseId: json['franchise_id']?.toString() ?? '',
      menuType: json['menu_type'] ?? '',
      menuCategoryId: json['menu_category_id']?.toString(),
      menuName: json['menu_name'] ?? '',
      dietType: json['diet_type'] ?? '',
      halal: json['halal'] ?? '',
      description: json['description'] ?? '',
      basePrice: double.tryParse(json['base_price']?.toString() ?? '0') ?? 0,
      currentPrice: double.tryParse(json['current_price']?.toString() ?? '0') ?? 0,
      menuStock: json['menu_stock']?.toString(),
      menuImage: fullImage,
      scrollingText: json['scrolling_text']?.toString(),
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}


