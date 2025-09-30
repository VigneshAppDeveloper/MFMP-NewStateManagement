import '../../config/app_config.dart';
import '../PickUpPointModel/pickup_point.dart';

class Restaurant {
  final String franchiseId;
  final String name;
  final String description;
  final String address;
  final String ownerName;
  final String mobile;
  final String image;
  final double franchiseLatitude;
  final double franchiseLongitude;
  final double distanceKm;
  final double franchiseRating;
  final int totalRating;
  final List<PickpointModel> pickupPoints;

  Restaurant({
    required this.franchiseId,
    required this.name,
    required this.description,
    required this.address,
    required this.ownerName,
    required this.mobile,
    required this.image,
    required this.distanceKm,
    required this.franchiseLatitude,
    required this.franchiseLongitude,
    required this.franchiseRating,
    required this.totalRating,
    required this.pickupPoints,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    // ✅ Fix image path
    String rawImage = json['franchise_image']?.toString() ?? '';
    String fullImage =
        rawImage.isNotEmpty && !rawImage.startsWith('http')
            ? AppConfig.instance.storageBaseUrl + rawImage
            : rawImage;

    return Restaurant(
      franchiseId: json['franchise_id']?.toString() ?? '',
      name: json['franchise']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      image: fullImage,
      franchiseLatitude: toDouble(json['latitude']),
      franchiseLongitude: toDouble(json['longitude']),
      distanceKm: toDouble(json['distance_km']),
      franchiseRating: toDouble(json['franchise_rating']),
      totalRating: toInt(json['total_rating']),
      pickupPoints:
          (json['pickup_points'] as List<dynamic>? ?? [])
              .map((e) => PickpointModel.fromJson(e))
              .toList(),
    );
  }
}

// class Restaurant {
//   final String name;
//   final double rating;
//   final String area;
//   final String distanceKm; // "6.7 km"
//   final String cuisines; // "Chicken Biryani, Mutton Biryani.."
//   final String image; // asset or network

//   Restaurant({
//     required this.name,
//     required this.rating,
//     required this.area,
//     required this.distanceKm,
//     required this.cuisines,
//     required this.image,
//   });
// }
