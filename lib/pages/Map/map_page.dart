import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_food_my_price/pages/Map/pickup_points_page.dart';
import 'package:my_food_my_price/util/map_makers_util.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_loader.dart';
import 'package:provider/provider.dart';
import '../../Providers/restaurant_provider.dart';
import '../../models/Resturant Model/resturant.dart';
import '../../services/location_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key}); 

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  LatLng? userLatLng;

  Restaurant? selectedRestaurant;
  final Set<Marker> _markers = {};
  final Map<String, BitmapDescriptor> markerIconCache = {};

  @override
  void initState() {
    super.initState();
    fetchUserLocation();
  }

  Future<void> fetchUserLocation() async {
    final loc = await LocationService.getCurrentLatLng();
    if (mounted) setState(() => userLatLng = loc);
  }

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

  Future<void> prepareMarkers(List<Restaurant> restaurants) async {
    final Set<Marker> updatedMarkers = {};

    for (var r in restaurants) {
      final markerIcon = await getCachedMarkerIcon(
        r.name,
        selectedRestaurant?.franchiseId == r.franchiseId,
      );

      updatedMarkers.add(
        Marker(
          markerId: MarkerId(r.franchiseId),
          position: LatLng(r.latitude, r.longitude),
          icon: markerIcon,
          onTap: () {
            if (selectedRestaurant?.franchiseId != r.franchiseId) {
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

  bool _isWithinRadius(LatLng user, LatLng point, double km) {
    const earthRadius = 6371;
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

  // 🔧 Helper: Re-center map to user location
  void _centerToUserLocation() {
    if (userLatLng != null) {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(userLatLng!, 15));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, _) {
        if (userLatLng != null) {
          // ✅ schedule markers update AFTER this frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              prepareMarkers(provider.restaurants);
            }
          });
        }

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
                  mapController.animateCamera(
                    CameraUpdate.newLatLng(userLatLng!),
                  );
                },
                onCameraIdle: () async {
                  final center = await mapController.getLatLng(
                    ScreenCoordinate(
                      x: (MediaQuery.of(context).size.width ~/ 2),
                      y: (MediaQuery.of(context).size.height ~/ 2),
                    ),
                  );

                  if (!_isWithinRadius(userLatLng!, center, 10)) {
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

            // ✅ Restaurant card (when marker tapped)
            if (selectedRestaurant != null && userLatLng != null)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: buildRestaurantCard(context, selectedRestaurant!),
              ),

            // ✅ Loader
            if (userLatLng == null || provider.isLoading)
              const FullScreenLoader(
                size: 35,
                strokeWidth: 3,
                backgroundColor: Color(0x80000000),
              ),

            // ✅ Empty state overlay (no restaurants)
            if (provider.restaurants.isEmpty && !provider.isLoading)
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.03,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 40,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "No Restaurants Found Nearby",
                        style: Styles.textStyleMedium(
                          context,
                        ).copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Expand your search area or try again later.",
                        style: Styles.textSmall(context, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            // ✅ Floating re-center button
            if (userLatLng != null && provider.restaurants.isNotEmpty)
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.1,
                right: MediaQuery.of(context).size.width * 0.04,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  onPressed: _centerToUserLocation,
                  child: const Icon(Icons.my_location),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildRestaurantCard(BuildContext context, Restaurant restaurant) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => PickupPointsPage(restaurant: restaurant),
        //   ),
        // );
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
              child: Image.network(
                restaurant.image,
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
                  Text(
                    restaurant.name,
                    style: Styles.textStyleMedium(context),
                    textScaler: TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.franchiseRating.toString(),
                        style: Styles.textSmall(context),
                        textScaler: TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    restaurant.address,
                    style: Styles.textSmall(context),
                    textScaler: const TextScaler.linear(1.0),
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
