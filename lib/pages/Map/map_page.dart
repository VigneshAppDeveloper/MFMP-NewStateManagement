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
  GoogleMapController? _mapController;
  LatLng? userLatLng;

  Restaurant? selectedRestaurant;
  final Set<Marker> _markers = {};
  final Map<String, BitmapDescriptor> markerIconCache = {};

  // ✅ Cache last camera position
  CameraPosition? _lastCameraPosition;

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

  Future<void> _updateMarkers(List<Restaurant> restaurants) async {
    final Set<Marker> updatedMarkers = {};

    for (var r in restaurants) {
      final markerIcon = await getCachedMarkerIcon(
        r.name,
        selectedRestaurant?.franchiseId == r.franchiseId,
      );

      updatedMarkers.add(
        Marker(
          markerId: MarkerId(r.franchiseId),
          position: LatLng(r.franchiseLatitude, r.franchiseLongitude),
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

  void _fitCamera(LatLng user, List<Restaurant> restaurants) {
    if (_mapController == null || restaurants.isEmpty) return;

    final bounds = restaurants.fold<LatLngBounds>(
      LatLngBounds(southwest: user, northeast: user),
      (bounds, r) {
        final point = LatLng(r.franchiseLatitude, r.franchiseLongitude);
        return LatLngBounds(
          southwest: LatLng(
            min(bounds.southwest.latitude, point.latitude),
            min(bounds.southwest.longitude, point.longitude),
          ),
          northeast: LatLng(
            max(bounds.northeast.latitude, point.latitude),
            max(bounds.northeast.longitude, point.longitude),
          ),
        );
      },
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  void _centerToUserLocation() {
    if (_mapController != null && userLatLng != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(userLatLng!, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, _) {
        if (userLatLng != null && provider.restaurants.isNotEmpty) {
          _updateMarkers(provider.restaurants);
          // ✅ Only fit if no previous camera is cached
          if (_lastCameraPosition == null) {
            _fitCamera(userLatLng!, provider.restaurants);
          }
        }

        return Stack(
          children: [
            if (userLatLng != null)
              GoogleMap(
                initialCameraPosition: _lastCameraPosition ??
                    CameraPosition(target: userLatLng!, zoom: 14),
                myLocationEnabled: true,
                markers: _markers,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                // ✅ Save last camera position whenever it moves
                onCameraMove: (position) {
                  _lastCameraPosition = position;
                },
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

            if (userLatLng == null || provider.isLoading)
              const FullScreenLoader(
                size: 35,
                strokeWidth: 3,
                backgroundColor: Color(0x80000000),
              ),

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
                      const Icon(Icons.restaurant_menu, size: 40, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        "No Restaurants Found Nearby",
                        style: Styles.textStyleMedium(context)
                            .copyWith(fontWeight: FontWeight.w700),
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
