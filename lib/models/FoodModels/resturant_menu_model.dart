import 'package:flutter/material.dart';
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
  final int menuStock;
  final int soldStocks;
  final int avaliableStocks;
  final bool isFlash;
  final double? flashPrice;
  final DateTime? flashStart;
  final DateTime? flashEnd;
  final String menuImage;
  final String? scrollingText;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MenuTag> tags;
  final List<MenuRating> ratings;
  final int ratingsCount;
  final double? avgStarRating;
  final double? flashDiscount;
  final double parcelCharges;

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
    required this.menuStock,
    required this.soldStocks,
    required this.avaliableStocks,
    required this.isFlash,
    this.flashPrice,
    this.flashStart,
    this.flashEnd,
    required this.menuImage,
    this.scrollingText,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.ratings,
    required this.ratingsCount,
    this.avgStarRating,
    this.flashDiscount,
    required this.parcelCharges,
  });

  // ---------------- SAFE PARSERS ----------------
  static int _safeInt(dynamic val, String field) {
    try {
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    } catch (e) {
      debugPrint("⚠️ Failed to parse int for $field: $val");
      return 0;
    }
  }

  static double _safeDouble(dynamic val, String field) {
    try {
      return double.tryParse(val?.toString() ?? '0') ?? 0.0;
    } catch (e) {
      debugPrint("⚠️ Failed to parse double for $field: $val");
      return 0.0;
    }
  }

  static DateTime? _safeDate(dynamic val, String field) {
    if (val == null) return null;
    try {
      return DateTime.parse(val.toString());
    } catch (e) {
      debugPrint("⚠️ Failed to parse date for $field: $val");
      return null;
    }
  }

  // ---------------- FROM JSON ----------------
  factory RestaurantMenuModel.fromJson(Map<String, dynamic> json) {
    String rawImage = json['menu_image']?.toString() ?? '';
    String fullImage =
        rawImage.isNotEmpty && !rawImage.startsWith('http')
            ? AppConfig.instance.storageBaseUrl + rawImage
            : rawImage;

    final List<MenuTag> tags =
        (json['tag'] as List?)?.map((e) => MenuTag.fromJson(e)).toList() ?? [];

    final List<MenuRating> ratings =
        (json['ratings'] as List?)
            ?.map((e) => MenuRating.fromJson(e))
            .toList() ??
        [];

    return RestaurantMenuModel(
      id: _safeInt(json['id'], 'id'),
      franchiseId: json['franchise_id']?.toString() ?? '',
      menuType:
          json['menu_type']?.toString() ??
          (json['is_flash'].toString() == '1' ? 'Fixed Price' : ''),
      menuCategoryId: json['menu_category_id']?.toString(),
      menuName: json['menu_name']?.toString() ?? '',
      dietType: json['diet_type']?.toString() ?? '',
      halal: json['halal']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      basePrice: _safeDouble(json['base_price'], 'base_price'),
      currentPrice: _safeDouble(json['current_price'], 'current_price'),
      flashPrice:
          json['flash_price'] != null
              ? _safeDouble(json['flash_price'], 'flash_price')
              : null,
      menuStock: _safeInt(json['menu_stock'], 'menu_stock'),
      soldStocks: _safeInt(json['sold_stocks'], 'sold_stocks'),
      avaliableStocks: _safeInt(json['avaliable_stocks'], 'avaliable_stocks'),
      isFlash: json['is_flash'].toString() == '1',
      flashStart: _safeDate(json['flash_start'], 'flash_start'),
      flashEnd: _safeDate(json['flash_end'], 'flash_end'),
      menuImage: fullImage,
      scrollingText: json['scrolling_text']?.toString(),
      parcelCharges: _safeDouble(json['parcel_charges'], 'parcel_charges'),
      status: json['status']?.toString() ?? '',
      createdAt: _safeDate(json['created_at'], 'created_at') ?? DateTime.now(),
      updatedAt: _safeDate(json['updated_at'], 'updated_at') ?? DateTime.now(),
      tags: tags,
      ratings: ratings,
      ratingsCount: _safeInt(json['ratings_count'], 'ratings_count'),
      avgStarRating:
          json['ratings_avg_star_rating'] != null
              ? _safeDouble(
                json['ratings_avg_star_rating'],
                'ratings_avg_star_rating',
              )
              : null,
      flashDiscount:
          json['flash_discount'] != null
              ? _safeDouble(json['flash_discount'], 'flash_discount')
              : null,
    );
  }

  RestaurantMenuModel copyWith({int? avaliableStocks}) {
    return RestaurantMenuModel(
      id: id,
      franchiseId: franchiseId,
      menuType: menuType,
      menuCategoryId: menuCategoryId,
      menuName: menuName,
      dietType: dietType,
      halal: halal,
      description: description,
      basePrice: basePrice,
      currentPrice: currentPrice,
      parcelCharges: parcelCharges,
      menuStock: menuStock,
      soldStocks: soldStocks,
      avaliableStocks: avaliableStocks ?? this.avaliableStocks,
      isFlash: isFlash,
      flashPrice: flashPrice,
      flashStart: flashStart,
      flashEnd: flashEnd,
      menuImage: menuImage,
      scrollingText: scrollingText,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags,
      ratings: ratings,
      ratingsCount: ratingsCount,
      avgStarRating: avgStarRating,
    );
  }
}

extension RestaurantMenuHelper on RestaurantMenuModel {
  /// If the page itself is flash (API param is_flash=1),
  /// UI will explicitly pass `true` when needed.
  double getDisplayPrice({required bool fromFlashPage}) {
    //  debugPrint(
    //   "💰 Menu: $menuName | is_flash=$isFlash | fromFlashPage=$fromFlashPage | "
    //   "current=$currentPrice | flash=$flashPrice | shown="
    //   "${(fromFlashPage && flashPrice != null && flashPrice! > 0) ? flashPrice! : currentPrice}",
    // );
    // ✅ On flash page → show flash price
    if (fromFlashPage && flashPrice != null && flashPrice! > 0) {
      return flashPrice!;
    }
    // ✅ On normal page → always show current price
    return currentPrice;
  }
}

class MenuTag {
  final int id;
  final String name;
  final String slug;
  final String kind;
  final String tagImage;

  MenuTag({
    required this.id,
    required this.name,
    required this.slug,
    required this.kind,
    required this.tagImage,
  });

  factory MenuTag.fromJson(Map<String, dynamic> json) {
    String rawImage = json['tag_image']?.toString() ?? '';
    String fullImage =
        rawImage.isNotEmpty && !rawImage.startsWith('http')
            ? AppConfig.instance.storageBaseUrl + rawImage
            : rawImage;

    return MenuTag(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      tagImage: fullImage,
    );
  }
}

class MenuRating {
  final int id;
  final String userId;
  final String menuId;
  final double starRating;
  final String? feedback;
  final DateTime createdAt;
  final RatingUser? user;

  MenuRating({
    required this.id,
    required this.userId,
    required this.menuId,
    required this.starRating,
    this.feedback,
    required this.createdAt,
    this.user,
  });

  factory MenuRating.fromJson(Map<String, dynamic> json) {
    return MenuRating(
      id: json['id'] ?? 0,
      userId: json['user_id']?.toString() ?? '',
      menuId: json['menu_id']?.toString() ?? '',
      starRating: double.tryParse(json['star_rating']?.toString() ?? '0') ?? 0,
      feedback: json['feed_back']?.toString(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      user: json['user'] != null ? RatingUser.fromJson(json['user']) : null,
    );
  }
}

class RatingUser {
  final int id;
  final String name;

  RatingUser({required this.id, required this.name});

  factory RatingUser.fromJson(Map<String, dynamic> json) {
    return RatingUser(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
