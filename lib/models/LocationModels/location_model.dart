class LocationModel {
  final String address;
  final String state;
  final String district;
  final String pincode;
  final double latitude;
  final double longitude;
  final String areaName; // 👈 NEW FIELD

  LocationModel({
    required this.address,
    required this.state,
    required this.district,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.areaName,
  });

  Map<String, dynamic> toJson() => {
        'address': address,
        'state': state,
        'district': district,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
        'areaName': areaName,
      };

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        address: json['address'],
        state: json['state'],
        district: json['district'],
        pincode: json['pincode'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        areaName: json['areaName'] ?? '',
      );
}
