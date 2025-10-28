import '../../config/app_config.dart';
import '../PickUptModels/block_out_date_model.dart';
import '../PickUptModels/pickup_point.dart';

class Restaurant {
  final String franchiseId;
  final String name;
  final String description;
  final String address;
  final String ownerName;
  final String mobile;
  final String image;
  final String fssaiCertificate;
  final String gstCertificate;
  final double franchiseLatitude;
  final double franchiseLongitude;
  final double distanceKm;
  final double franchiseRating;
  final int totalRating;

  // ✅ newly added parameters
  final String pureVeg; // "yes"/"no"
  final int halal;
  final int halalLiving;
  final int isFlash;
  final List<BlockoutDateModel> blockoutDates;
  final List<PickpointModel> pickupPoints;

  Restaurant({
    required this.franchiseId,
    required this.name,
    required this.description,
    required this.address,
    required this.ownerName,
    required this.mobile,
    required this.image,
    required this.fssaiCertificate,
    required this.gstCertificate,
    required this.distanceKm,
    required this.franchiseLatitude,
    required this.franchiseLongitude,
    required this.franchiseRating,
    required this.totalRating,
    required this.pureVeg,
    required this.halal,
    required this.halalLiving,
    required this.isFlash,
    required this.pickupPoints,

    required this.blockoutDates,
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

    String withStorageUrl(String? path) {
      if (path == null || path.isEmpty) return '';
      return path.startsWith('http')
          ? path
          : AppConfig.instance.storageBaseUrl + path;
    }

    return Restaurant(
      franchiseId: json['franchise_id']?.toString() ?? '',
      name: json['franchise']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      image: withStorageUrl(json['franchise_image']),
      fssaiCertificate: withStorageUrl(json['fssai_certificate']),
      gstCertificate: withStorageUrl(json['gst_certificate']),
      franchiseLatitude: toDouble(json['latitude']),
      franchiseLongitude: toDouble(json['longitude']),
      distanceKm: toDouble(json['distance_km']),
      franchiseRating: toDouble(json['franchise_rating']),
      totalRating: toInt(json['total_rating']),

      // ✅ new fields
      pureVeg: json['pure_veg']?.toString() ?? '',
      halal: toInt(json['halal']),
      halalLiving: toInt(json['halal_living']),
      isFlash: toInt(json['is_flash']),
      blockoutDates:
          (json['blockout_dates'] as List<dynamic>? ?? [])
              .map((e) => BlockoutDateModel.fromJson(e))
              .toList(),
      pickupPoints:
          (json['pickup_points'] as List<dynamic>? ?? [])
              .map((e) => PickpointModel.fromJson(e))
              .toList(),
    );
  }
}

// class Restaurant {
//   final String franchiseId;
//   final String name;
//   final String description;
//   final String address;
//   final String ownerName;
//   final String mobile;
//   final String image;
//   final String fssaiCertificate;
//   final String gstCertificate;
//   final double franchiseLatitude;
//   final double franchiseLongitude;
//   final double distanceKm;
//   final double franchiseRating;
//   final String pureVeg;
//   final int totalRating;
//   final List<PickpointModel> pickupPoints;

//   Restaurant({
//     required this.franchiseId,
//     required this.name,
//     required this.description,
//     required this.address,
//     required this.ownerName,
//     required this.mobile,
//     required this.image,
//     required this.fssaiCertificate,
//     required this.gstCertificate,
//     required this.distanceKm,
//     required this.franchiseLatitude,
//     required this.franchiseLongitude,
//     required this.franchiseRating,
//     required this.totalRating,
//     required this.pureVeg,
//     required this.pickupPoints,
//   });

//   factory Restaurant.fromJson(Map<String, dynamic> json) {
//     double toDouble(dynamic value) {
//       if (value == null) return 0.0;
//       if (value is num) return value.toDouble();
//       if (value is String) return double.tryParse(value) ?? 0.0;
//       return 0.0;
//     }

//     int toInt(dynamic value) {
//       if (value == null) return 0;
//       if (value is int) return value;
//       if (value is String) return int.tryParse(value) ?? 0;
//       if (value is double) return value.toInt();
//       return 0;
//     }

//     String withStorageUrl(String? path) {
//       if (path == null || path.isEmpty) return '';
//       return path.startsWith('http')
//           ? path
//           : AppConfig.instance.storageBaseUrl + path;
//     }

//     return Restaurant(
//       franchiseId: json['franchise_id']?.toString() ?? '',
//       name: json['franchise']?.toString() ?? '',
//       description: json['description']?.toString() ?? '',
//       address: json['address']?.toString() ?? '',
//       ownerName: json['owner_name']?.toString() ?? '',
//       mobile: json['mobile']?.toString() ?? '',
//       image: withStorageUrl(json['franchise_image']),
//       fssaiCertificate: withStorageUrl(json['fssai_certificate']),
//       gstCertificate: withStorageUrl(json['gst_certificate']),
//       franchiseLatitude: toDouble(json['latitude']),
//       franchiseLongitude: toDouble(json['longitude']),
//       distanceKm: toDouble(json['distance_km']),
//       franchiseRating: toDouble(json['franchise_rating']),
//       totalRating: toInt(json['total_rating']),
//       pureVeg: json['pure_veg']?.toString().toLowerCase() ?? 'no',
//       pickupPoints:
//           (json['pickup_points'] as List<dynamic>? ?? [])
//               .map((e) => PickpointModel.fromJson(e))
//               .toList(),
//     );
//   }
// }
