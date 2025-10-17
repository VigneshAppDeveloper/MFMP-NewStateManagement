import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/Resturant Model/resturant.dart';
import '../../route_generator.dart';

class PickupPointsPage extends StatefulWidget {
  final Restaurant restaurant; // ✅ full Restaurant with pickupPoints

  const PickupPointsPage({super.key, required this.restaurant});

  @override
  State<PickupPointsPage> createState() => _PickupPointsPageState();
}

class _PickupPointsPageState extends State<PickupPointsPage> {
  GoogleMapController? mapController;
  int selectedIndex = 0;
  List<Marker> customMarkers = [];
  LatLng? userLatLng;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    loadCustomMarkers();
  }

  /// ✅ Load user’s current/session location
  Future<void> _loadUserLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      userLatLng = LatLng(pos.latitude, pos.longitude);
    });
  }

  /// ✅ Add pickup markers
  Future<void> loadCustomMarkers() async {
    List<Marker> temp = [];

    for (int i = 0; i < widget.restaurant.pickupPoints.length; i++) {
      final point = widget.restaurant.pickupPoints[i];
      final isSelected = (i == selectedIndex);

      // Marker icon changes if selected
      final icon = await createPickupMarker(point.pickupLocation, isSelected);

      // ⚡ Offset if same lat/lng for multiple points
      double lat = point.latitude;
      double lng = point.longitude;
      if (temp.any(
        (m) => (m.position.latitude == lat && m.position.longitude == lng),
      )) {
        lat += 0.00005 * i;
        lng += 0.00005 * i;
      }

      temp.add(
        Marker(
          markerId: MarkerId(point.pickupId.toString()),
          position: LatLng(lat, lng),
          icon: icon,
          onTap: () async {
            setState(() {
              selectedIndex = i;
            });
            await loadCustomMarkers(); // 🔁 reload with new highlight
          },
        ),
      );
    }

    if (mounted) {
      setState(() {
        customMarkers = temp;
      });
    }
  }

  /// ✅ Calculate distance (Haversine formula)
  String _calculateDistance(LatLng from, LatLng to) {
    const earthRadius = 6371; // km
    double dLat = _deg2rad(to.latitude - from.latitude);
    double dLng = _deg2rad(to.longitude - from.longitude);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(from.latitude)) *
            cos(_deg2rad(to.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance.toStringAsFixed(2); // return in km
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  @override
  Widget build(BuildContext context) {
    final selectedPickup = widget.restaurant.pickupPoints[selectedIndex];

    String distanceKm = "Calculating...";
    if (userLatLng != null) {
      distanceKm = _calculateDistance(
        userLatLng!,
        LatLng(selectedPickup.latitude, selectedPickup.longitude),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.restaurant.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.restaurant.pickupPoints.first.latitude,
                  widget.restaurant.pickupPoints.first.longitude,
                ),
                zoom: 13,
              ),
              onMapCreated: (controller) => mapController = controller,
              markers: Set.from(customMarkers),
            ),

            // ✅ Bottom Info Sheet
            Positioned(
              bottom:
                  MediaQuery.of(context).size.height *
                  0.00, // responsive bottom
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  vertical: MediaQuery.of(context).size.height * 0.018,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Title
                    Text(
                      "Pickup Points",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.012,
                    ),

                    // 🔹 Card Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.storefront,
                          size: 28,
                          color: Colors.black87,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.restaurant.name} (Pickup point ${selectedIndex + 1})",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                "${selectedPickup.pickupLocation}, $distanceKm km",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                    // 🔹 Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // 🚀 Pass restaurant + pickup point
                          AppRouteName.menuPage.push(
                            context,
                            args: {
                              'restaurant': widget.restaurant,
                              'showPriceTabs': true,
                            },
                          );
                        },
                        child: const Text(
                          "CONTINUE",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Custom marker with pickup point name
  Future<BitmapDescriptor> createPickupMarker(
    String label,
    bool isSelected,
  ) async {
    const double width = 150;
    const double height = 40;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint =
        Paint()..color = isSelected ? Colors.black : Colors.red; // 🟢 highlight

    // Rounded box
    final rRect = RRect.fromLTRBR(
      0,
      0,
      width,
      height - 10,
      const Radius.circular(10),
    );
    canvas.drawRRect(rRect, paint);

    // Triangle pointer
    final triangle =
        Path()
          ..moveTo(width / 2 - 10, height - 10)
          ..lineTo(width / 2 + 10, height - 10)
          ..lineTo(width / 2, height)
          ..close();
    canvas.drawPath(triangle, paint);

    // Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: width - 16);
    final offset = Offset(
      (width - textPainter.width) / 2,
      (height - 10 - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);

    final img = await recorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    return BitmapDescriptor.bytes(bytes);
  }
}
