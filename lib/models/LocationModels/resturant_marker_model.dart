
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RestaurantMarker {
  final String name;
  final LatLng latLng;
  final double rating;
  final String location;

  RestaurantMarker({
    required this.name,
    required this.latLng,
    required this.rating,
    required this.location,
  });
}
