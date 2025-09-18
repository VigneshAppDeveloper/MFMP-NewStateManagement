import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/services/location_service.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';

class ConfirmLocationMapPage extends StatefulWidget {
  final LatLng latLng;

  const ConfirmLocationMapPage({super.key, required this.latLng});

  @override
  State<ConfirmLocationMapPage> createState() => _ConfirmLocationMapPageState();
}

class _ConfirmLocationMapPageState extends State<ConfirmLocationMapPage> {
  String shortName = '';
  String fullAddress = '';
  late GoogleMapController _mapController;
  LatLng currentLatLng = const LatLng(0, 0);
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentLatLng = widget.latLng;
    fetchAddressDetails(currentLatLng);
  }

  void fetchAddressDetails(LatLng latLng) async {
    setState(() => isLoading = true);
    final data = await LocationService.getAddressFromLatLng(latLng);
    if (data != null && mounted) {
      setState(() {
        shortName = data['areaName']!;
        fullAddress = data['fullAddress']!;
        isLoading = false;
      });
    }
  }

  void _onCameraIdle() async {
    final center = await _mapController.getLatLng(
      ScreenCoordinate(
        x: MediaQuery.of(context).size.width ~/ 2,
        y: MediaQuery.of(context).size.height ~/ 2,
      ),
    );
    currentLatLng = center;
    fetchAddressDetails(center);
  }

  void _confirmLocation() async {
    final success = await LocationService.fetchAndSaveLocationFromLatLng(
      currentLatLng,
    );
    if (success && context.mounted) {
      AppRouteName.appPage.pushAndRemoveUntil(context, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.latLng,
              zoom: 17,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraIdle: _onCameraIdle,
            onCameraMove: (pos) => currentLatLng = pos.target,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          const Center(
            child: Icon(Icons.location_pin, size: 40, color: Colors.red),
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Material(
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              child: TextField(
                readOnly: true,
                onTap: () {
                  Navigator.pop(context); 
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search an area or address',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(blurRadius: 10, color: Colors.black.withAlpha(12)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order will be delivered here",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isLoading
                              ? "Fetching..."
                              : shortName.isNotEmpty
                              ? shortName
                              : fullAddress.split(',').first,
                          style: Styles.textStyleMedium(
                            context,
                            color: Colors.black,
                          ).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                          textScaler: TextScaler.linear(1.0),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fullAddress.isNotEmpty ? fullAddress : "Please wait...",
                    style: Styles.textExtraSmall(context, color: Colors.black),
                    textScaler: TextScaler.linear(1.0),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _confirmLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.blackColor,
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Confirm & proceed",
                      style: Styles.textSmall(context, color: Colors.white),
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
}
