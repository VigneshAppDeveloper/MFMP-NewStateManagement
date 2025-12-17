import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_food_my_price/pages/Map/route_observer.dart';
import 'package:my_food_my_price/pages/app_pages.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/map_makers_util.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_loader.dart';
import 'package:provider/provider.dart';
import '../../Providers/location_provider.dart';
import '../../Providers/restaurant_provider.dart';
import '../../components/HomePageDesigns/restaurant_wiget.dart';
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

  CameraPosition? _lastCameraPosition;

  @override
  void initState() {
    super.initState();

    _loadInitialLocation();
  }

 @override
void didChangeDependencies() {
  super.didChangeDependencies();

  final appState = context.findAncestorStateOfType<AppPagesState>();

  if (appState != null && appState.currentTabIndex == 1) {
    selectedRestaurant = null;
    _markers.clear();
    markerIconCache.clear();
    _lastCameraPosition = null;

    setState(() {});
  }
}


  Future<void> _loadInitialLocation() async {
    selectedRestaurant = null; // 🔥 FIX 3
    final locProvider = context.read<LocationProvider>();
    final restProvider = context.read<RestaurantProvider>();

    final sessionLocation = locProvider.currentLocation;
    if (sessionLocation != null) {
      setState(() {
        userLatLng = LatLng(
          sessionLocation.latitude,
          sessionLocation.longitude,
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await restProvider.loadAllRestaurants(
          lat: sessionLocation.latitude,
          lng: sessionLocation.longitude,
        );
      });
    } else {
      final gpsLoc = await LocationService.getCurrentLatLng();
      if (mounted && gpsLoc != null) {
        setState(() => userLatLng = gpsLoc);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await restProvider.loadAllRestaurants(
            lat: gpsLoc.latitude,
            lng: gpsLoc.longitude,
          );
        });
      }
    }
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
    if (restaurants.isEmpty) return;

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
            setState(() {
              if (selectedRestaurant?.franchiseId == r.franchiseId) {
                selectedRestaurant = null; // UNSELECT
              } else {
                selectedRestaurant = r; // SELECT
              }
            });
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

  void _fitCamera(LatLng center, List<Restaurant> restaurants) {
    if (_mapController == null || restaurants.isEmpty) return;

    final bounds = restaurants.fold<LatLngBounds>(
      LatLngBounds(southwest: center, northeast: center),
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

  void _centerToSessionLocation() {
    final loc = context.read<LocationProvider>().currentLocation;
    if (_mapController != null && loc != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(loc.latitude, loc.longitude), 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationProvider, RestaurantProvider>(
      builder: (context, locationProvider, restaurantProvider, _) {
        final sessionLoc = locationProvider.currentLocation;
        if (sessionLoc != null) {
          if (userLatLng == null ||
              userLatLng!.latitude != sessionLoc.latitude ||
              userLatLng!.longitude != sessionLoc.longitude) {
            selectedRestaurant = null;
            _markers.clear();
            _lastCameraPosition = null;
          }

          userLatLng = LatLng(sessionLoc.latitude, sessionLoc.longitude);
        }

        final mapRestaurants = restaurantProvider.mapRestaurants;
        if (userLatLng != null && mapRestaurants.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateMarkers(mapRestaurants);
          });
          if (_lastCameraPosition == null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(userLatLng!, 15),
            );
          }
        }

        return Stack(
          children: [
            if (userLatLng != null)
              GoogleMap(
                initialCameraPosition:
                    _lastCameraPosition ??
                    CameraPosition(target: userLatLng!, zoom: 14),
                myLocationEnabled: true,
                markers: _markers,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                onCameraMove: (pos) {
                  _lastCameraPosition = pos;
                },
              ),
            if (selectedRestaurant != null && userLatLng != null)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    AppRouteName.menuPage.push(
                      context,
                      args: {
                        'restaurant': selectedRestaurant!,
                        'showPriceTabs': true,
                      },
                    );
                  },
                  child: RestaurantCard(
                    data: selectedRestaurant!,
                  ), // 👈 existing UI reused
                ),
              ),

            if (userLatLng == null || restaurantProvider.isMapLoading)
              const FullScreenLoader(
                size: 35,
                strokeWidth: 3,
                backgroundColor: Color(0x80000000),
              ),

            // if (restaurantProvider.mapRestaurants.isEmpty &&
            //     !restaurantProvider.isLoading)
            // Center(
            //   child: Text(
            //     "",
            //     style: Styles.textStyleMedium(
            //       context,
            //     ).copyWith(fontWeight: FontWeight.w700),
            //   ),
            // ),
            if (userLatLng != null &&
                restaurantProvider.mapRestaurants.isNotEmpty)
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.1,
                right: MediaQuery.of(context).size.width * 0.04,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  onPressed: _centerToSessionLocation,
                  child: const Icon(Icons.my_location),
                ),
              ),
          ],
        );
      },
    );
  }
}
