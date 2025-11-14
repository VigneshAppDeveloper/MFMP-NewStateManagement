import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_food_my_price/Providers/location_provider.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

class EnableLocationScreen extends StatelessWidget {
  const EnableLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset('assets/icons/location_permission.png', height: 160),
            const SizedBox(height: 30),
            Text(
              "Enable location to find restaurants near you",
              textAlign: TextAlign.center,
              style: Styles.textSmall(context),
              textScaler: TextScaler.linear(1.0),
            ),
            const SizedBox(height: 10),
            Text(
              "We use your location to show the best food nearby.",
              textAlign: TextAlign.center,
              style: Styles.textSmall(context),
              textScaler: TextScaler.linear(1.0),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                final granted = await Geolocator.requestPermission().then(
                  (p) =>
                      p == LocationPermission.always ||
                      p == LocationPermission.whileInUse,
                );
                if (granted) {
                  await context.read<LocationProvider>().loadGpsLocation();
                  if (context.mounted) {
                   AppRouteName.splashPage.pushAndRemoveUntil(
                      context,
                      (route) => false,
                    );
                  }
                } else {
                  await Geolocator.openAppSettings();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.maincolor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Turn On Location",
                style: TextStyle(color: Colors.white, fontSize: 16),
                textScaler: TextScaler.linear(1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
