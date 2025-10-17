import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

import '../../Providers/location_provider.dart';
import '../../Providers/restaurant_provider.dart';
import '../../services/location_service.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, provider, _) {
        final location = provider.currentLocation;

        final mainAddressLine =
            location == null
                ? "Loading..."
                : (location.areaName.isNotEmpty
                    ? location.areaName
                    : location.district);
        final subAddressLine = location?.address ?? "Fetching address...";

        return Row(
          children: [
            // 🔻 Address section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await AppRouteName.serachLocation
                          .push<LatLng>(context);
                      if (result != null && context.mounted) {
                        // 1. Update restaurants
                        context.read<RestaurantProvider>().getRestaurants(
                          lat: result.latitude,
                          lng: result.longitude,
                        );

                        // 2. Save & reload location into provider
                        final success =
                            await LocationService.fetchAndSaveLocationFromLatLng(
                              result,
                            );
                        if (success) {
                          final saved =
                              await LocationService.getSavedLocation();
                          if (saved != null && context.mounted) {
                            context
                                .read<LocationProvider>()
                                .updateSessionLocation(saved);
                          }
                        }
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 22),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            mainAddressLine,
                            style: Styles.textStyleMedium(
                              context,
                            ).copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            textScaler: const TextScaler.linear(1.0),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subAddressLine,
                    style: Styles.textExtraSmall(context),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textScaler: const TextScaler.linear(1.0),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // 💰 Wallet section
            GestureDetector(
              onTap: () {
                AppRouteName.rewards.push(context);
              },
              child: Image.asset('assets/icons/reward.gif', height: 30),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                AppConstants.profile?.wallet ?? '0',
                style: Styles.textSmall(
                  context,
                ).copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                textScaler: const TextScaler.linear(1.0),
              ),
            ),

            const SizedBox(width: 12),

            // 👤 Profile
            GestureDetector(
              onTap: () {
                AppRouteName.appSettingsPage.push(context);
              },
              child: const CircleAvatar(
                radius: 19,
                backgroundColor: Colors.black,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
