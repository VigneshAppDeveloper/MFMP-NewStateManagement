// class Restaurant {
//   final String franchiseId;
//   final String name;
//   final String description;
//   final String address;
//   final String ownerName;
//   final String mobile;
//   final String image;
//   final double distanceKm;

//   Restaurant({
//     required this.franchiseId,
//     required this.name,
//     required this.description,
//     required this.address,
//     required this.ownerName,
//     required this.mobile,
//     required this.image,
//     required this.distanceKm,
//   });

//   factory Restaurant.fromJson(Map<String, dynamic> json) {
//   return Restaurant(
//     franchiseId: json['franchise_id'].toString(),
//     name: json['franchise'].toString(),
//     description: json['description'].toString(),
//     address: json['address'].toString(),
//     ownerName: json['owner_name'].toString(),
//     mobile: json['mobile'].toString(),
//     image: json['franchise_image'].toString(),
//     distanceKm: (json['distance_km'] as num).toDouble(),
//   );
// }

// }
class Restaurant {
  final String name;
  final double rating;
  final String area;
  final String distanceKm; // "6.7 km"
  final String cuisines; // "Chicken Biryani, Mutton Biryani.."
  final String image; // asset or network

  Restaurant({
    required this.name,
    required this.rating,
    required this.area,
    required this.distanceKm,
    required this.cuisines,
    required this.image,
  });
}
