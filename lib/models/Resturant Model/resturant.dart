class Restaurant {
  final String franchiseId;
  final String name;
  final String description;
  final String address;
  final String ownerName;
  final String mobile;
  final String image;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final double franchiseRating; // ✅ new
  final int totalRating;        // ✅ new

  Restaurant({
    required this.franchiseId,
    required this.name,
    required this.description,
    required this.address,
    required this.ownerName,
    required this.mobile,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.franchiseRating,
    required this.totalRating,
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

    return Restaurant(
      franchiseId: json['franchise_id']?.toString() ?? '',
      name: json['franchise']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      image: json['franchise_image']?.toString() ?? '',
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),
      distanceKm: toDouble(json['distance_km']),
      franchiseRating: toDouble(json['franchise_rating']), // ✅ safe parse
      totalRating: toInt(json['total_rating']),            // ✅ safe parse
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
