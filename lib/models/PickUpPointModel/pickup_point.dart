class PickpointModel {
  final int pickupId;
  final String ownerName;
  final String ownerNumber;
  final String pickupLocation;
  final double latitude;
  final double longitude;
  final String googleMapLink;
  final double ppDistance;

  PickpointModel({
    required this.pickupId,
    required this.ownerName,
    required this.ownerNumber,
    required this.pickupLocation,
    required this.latitude,
    required this.longitude,
    required this.googleMapLink,
    required this.ppDistance,
  });

  factory PickpointModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return PickpointModel(
      pickupId: int.tryParse(json['pickup_id'].toString()) ?? 0,
      ownerName: json['owner_name']?.toString() ?? '',
      ownerNumber: json['owner_number']?.toString() ?? '',
      pickupLocation: json['pickup_location']?.toString() ?? '',
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),
      googleMapLink: json['googlemap_link']?.toString() ?? '',
      ppDistance: toDouble(json['pp_distance']),
    );
  }
}
