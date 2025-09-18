import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/LocationModels/resturant_marker_model.dart';
import '../../route_generator.dart';

class PickupPointsPage extends StatefulWidget {
  final RestaurantMarker restaurant;
  const PickupPointsPage({super.key, required this.restaurant});

  @override
  State<PickupPointsPage> createState() => _PickupPointsPageState();
}

class _PickupPointsPageState extends State<PickupPointsPage> {
  late GoogleMapController mapController;

  final List<Map<String, dynamic>> pickupPoints = [
    {'name': 'Pickup Point 1', 'latLng': LatLng(11.341, 77.716)},
    {'name': 'Pickup Point 2', 'latLng': LatLng(11.343, 77.719)},
    {'name': 'Pickup Point 3', 'latLng': LatLng(11.345, 77.717)},
  ];

  int selectedIndex = 0;

  List<Marker> customMarkers = [];

  @override
  void initState() {
    super.initState();
    loadCustomMarkers();
  }

  Future<void> loadCustomMarkers() async {
    List<Marker> temp = [];

    for (int i = 0; i < pickupPoints.length; i++) {
      final point = pickupPoints[i];
      final icon = await createPickupMarker(point['name']);
      temp.add(
        Marker(
          markerId: MarkerId(point['name']),
          position: point['latLng'],
          icon: icon,
          onTap: () {
            setState(() {
              selectedIndex = i;
            });
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

  @override
  Widget build(BuildContext context) {
    final selectedPickup = pickupPoints[selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.restaurant.name,
          textScaler: TextScaler.linear(1.0),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: pickupPoints[0]['latLng'],
              zoom: 14,
            ),
            onMapCreated: (controller) => mapController = controller,
            markers: Set.from(customMarkers),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Pickup Points",
                    style: Theme.of(context).textTheme.titleMedium,
                    textScaler: TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${widget.restaurant.name} (${selectedPickup['name']})",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.restaurant.location} • ${widget.restaurant.rating} ★",
                    style: TextStyle(color: Colors.grey.shade600),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      // AppRouteName.menuPage.push(
                      //   context,
                      //   args: {
                      //     'restaurant': widget.restaurant,
                      //     'shopPrice':
                      //         true, // 👈 indicates homepage restaurant menu
                      //   },
                      // );
                       AppRouteName.appPage.push(context);
                    },
                    child: const Text(
                      "NEXT",
                      textScaler: TextScaler.linear(1.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<BitmapDescriptor> createPickupMarker(String label) async {
    const double width = 150;
    const double height = 40;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.red;

    // Draw red rounded box
    final rRect = RRect.fromLTRBR(
      0,
      0,
      width,
      height - 10,
      const Radius.circular(10),
    );
    canvas.drawRRect(rRect, paint);

    // Draw triangle pointer
    final triangle =
        Path()
          ..moveTo(width / 2 - 10, height - 10)
          ..lineTo(width / 2 + 10, height - 10)
          ..lineTo(width / 2, height)
          ..close();
    canvas.drawPath(triangle, paint);

    // Draw centered white text
    final textPainter = TextPainter(
      textScaler: TextScaler.linear(1.0),
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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
