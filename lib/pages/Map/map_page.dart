import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_food_my_price/models/LocationModels/resturant_marker_model.dart';
import 'package:my_food_my_price/pages/Map/pickup_points_page.dart';
import 'package:my_food_my_price/util/map_makers_util.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_loader.dart';
import '../../services/location_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  LatLng? userLatLng;

  // Example static restaurants (later will come from backend)
  final List<RestaurantMarker> staticRestaurants = [
    RestaurantMarker(
      name: 'SS Hydrabad Biryani',
      latLng: const LatLng(10.7205, 79.1410),
      rating: 4.3,
      location: "Nagapattinam Main Rd",
    ),
    RestaurantMarker(
      name: 'Biryani Palace',
      latLng: const LatLng(10.7212, 79.1420),
      rating: 4.5,
      location: "Near Bus Stand, Nagapattinam",
    ),
    RestaurantMarker(
      name: 'Tandoori House',
      latLng: const LatLng(10.7195, 79.1405),
      rating: 4.1,
      location: "Opposite Railway Station",
    ),
    RestaurantMarker(
      name: 'Grill & BBQ Corner',
      latLng: const LatLng(10.7200, 79.1425),
      rating: 4.6,
      location: "Beach Road, Nagapattinam",
    ),
  ];

  RestaurantMarker? selectedRestaurant;
  final Set<Marker> _markers = {};
  final Map<String, BitmapDescriptor> markerIconCache = {};

  Future<BitmapDescriptor> getCachedMarkerIcon(
    String text,
    bool isSelected,
  ) async {
    final key = '${text}_${isSelected ? "selected" : "normal"}';
    if (markerIconCache.containsKey(key)) return markerIconCache[key]!;

    final icon = await createCustomMarker(text, isSelected: isSelected);
    markerIconCache[key] = icon;
    return icon;
  }

  @override
  void initState() {
    super.initState();
    Future.wait([fetchUserLocation(), prepareCustomMarkers()]);
  }

  Future<void> fetchUserLocation() async {
    final loc = await LocationService.getCurrentLatLng();
    if (mounted) setState(() => userLatLng = loc);
  }

  Future<void> prepareCustomMarkers() async {
    final Set<Marker> updatedMarkers = {};
    for (var r in staticRestaurants) {
      final markerIcon = await getCachedMarkerIcon(
        r.name,
        selectedRestaurant?.name == r.name,
      );
      updatedMarkers.add(
        Marker(
          markerId: MarkerId(r.name),
          position: r.latLng,
          icon: markerIcon,
          onTap: () {
            if (selectedRestaurant?.name != r.name) {
              setState(() => selectedRestaurant = r);
            }
          },
        ),
      );
    }
    if (mounted) {
      setState(() {
        _markers
          ..clear()
          ..addAll(updatedMarkers);
      });
    }
  }

  /// Helper: Check if location is within X km of user
  bool _isWithinRadius(LatLng user, LatLng point, double km) {
    const earthRadius = 6371; // km
    final dLat = (point.latitude - user.latitude) * (pi / 180);
    final dLng = (point.longitude - user.longitude) * (pi / 180);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(user.latitude * pi / 180) *
            cos(point.latitude * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return (earthRadius * c) <= km;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (userLatLng != null)
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userLatLng!,
              zoom: 15,
            ),
            myLocationEnabled: true,
            onMapCreated: (controller) {
              mapController = controller;
              mapController.animateCamera(CameraUpdate.newLatLng(userLatLng!));
            },
            onCameraIdle: () async {
              final center = await mapController.getLatLng(
                ScreenCoordinate(
                  x: (MediaQuery.of(context).size.width ~/ 2),
                  y: (MediaQuery.of(context).size.height ~/ 2),
                ),
              );

              if (!_isWithinRadius(userLatLng!, center, 10)) {
                // 👇 only after drag finishes, snap back
                mapController.animateCamera(
                  CameraUpdate.newLatLng(userLatLng!),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "You can only view restaurants within 10 km.",
                      ),
                    ),
                  );
                }
              }
            },
            markers: _markers,
          )
        else
          const SizedBox.shrink(),

        if (selectedRestaurant != null && userLatLng != null)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: buildRestaurantCard(context, selectedRestaurant!),
          ),

        if (userLatLng == null)
          const FullScreenLoader(
            size: 35,
            strokeWidth: 3,
            backgroundColor: Color(0x80000000),
          ),
      ],
    );
  }

  Widget buildRestaurantCard(
    BuildContext context,
    RestaurantMarker restaurant,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PickupPointsPage(restaurant: restaurant),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withAlpha(30)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/icons/MFMP-logo-1.jpg',
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name, style: Styles.textStyleMedium(context)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toString(),
                        style: Styles.textSmall(context),
                        textScaler: TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    restaurant.location,
                    style: Styles.textSmall(context),
                    textScaler: TextScaler.linear(1.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
