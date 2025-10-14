import 'package:my_food_my_price/config/app_config.dart';

class WinnerModel {
  final String status;
  final String date;
  final String description;
  final String timerId;
  final String timeSlot;
  final String franchiseId;
  final String menuName;
  final String finalPrice;
  final String name;
  final String menuId;
  final String userId;
  final String createdAt;
  final String menuImage;

  WinnerModel({
    required this.status,
    required this.date,
    required this.description,
    required this.timerId,
    required this.timeSlot,
    required this.franchiseId,
    required this.menuName,
    required this.finalPrice,
    required this.name,
    required this.menuId,
    required this.userId,
    required this.createdAt,
    required this.menuImage,
  });

  factory WinnerModel.fromJson(Map<String, dynamic> json) {
    // ✅ Ensure proper image path (like RestaurantMenuModel)
    String rawImage = json['menu_image']?.toString() ?? '';
    String fullImage =
        rawImage.isNotEmpty && !rawImage.startsWith('http')
            ? AppConfig.instance.storageBaseUrl + rawImage
            : rawImage;

    return WinnerModel(
      status: json['status']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      timerId: json['timer_id']?.toString() ?? '',
      timeSlot: json['time_slot']?.toString() ?? '',
      franchiseId: json['franchise_id']?.toString() ?? '',
      menuName: json['menu_name']?.toString() ?? '',
      finalPrice: json['final_price']?.toString() ?? '0',
      name: json['name']?.toString() ?? '',
      menuId: json['menu_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      menuImage: fullImage, // ✅ Use processed full URL here
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'date': date,
      'description': description,
      'timer_id': timerId,
      'time_slot': timeSlot,
      'franchise_id': franchiseId,
      'menu_name': menuName,
      'final_price': finalPrice,
      'name': name,
      'menu_id': menuId,
      'user_id': userId,
      'created_at': createdAt,
      'menu_image': menuImage,
    };
  }
}

class LoserData {
  final String userId;
  final String menuId;

  LoserData({required this.userId, required this.menuId});

  factory LoserData.fromJson(Map<String, dynamic> json) {
    return LoserData(
      userId: json['user_id']?.toString() ?? '',
      menuId: json['menu_id']?.toString() ?? '',
    );
  }
}
