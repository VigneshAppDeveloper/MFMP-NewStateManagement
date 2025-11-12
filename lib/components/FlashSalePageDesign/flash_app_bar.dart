

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

import '../../Providers/location_provider.dart';
import '../../Providers/restaurant_provider.dart';
import '../../route_generator.dart';
import '../../services/location_service.dart';
import '../../util/app_contant.dart';
import '../HomePageDesigns/home_search_bar.dart';

class FlashBanner extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onFilterTap;

  const FlashBanner({
    super.key,
    required this.searchController,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.height * 0.01,
      ),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg/flashsalebg-min.png"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FlashTopRow(),
            SizedBox(height: size.height * 0.012),

            // ✅ unified search bar design
            HomeSearchBar(
              controller: searchController,
              enableNavigation: true, // tap → RestaurantSearchPage
              isFlash: true,
               hintText: "Search for flash restaurants",
             onFilterTap: onFilterTap,
              onChanged: (_) {}, // no local logic
            ),

            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }
}


class FlashTopRow extends StatelessWidget {
  const FlashTopRow({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
            // 🔹 Address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await AppRouteName.serachLocation
                          .push<LatLng>(context);
                      if (result != null && context.mounted) {
                        context.read<RestaurantProvider>().getRestaurants(
                          lat: result.latitude,
                          lng: result.longitude,
                          isFlash: true,
                        );
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
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            mainAddressLine,
                            style: Styles.textStyleMedium(
                              context,
                              color: Colors.white,
                            ).copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            textScaler: const TextScaler.linear(1.0),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subAddressLine,
                    style: Styles.textExtraSmall(context, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textScaler: const TextScaler.linear(1.0),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // 🔹 Wallet
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
                color: Colors.white,
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

            // 🔹 Profile
            GestureDetector(
              onTap: () => AppRouteName.appSettingsPage.push(context),
              child: const CircleAvatar(
                radius: 19,
                backgroundColor: Colors.white,
                child: Icon(Icons.person_outline, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}

// class FlashCountdownRow extends StatelessWidget {
//   final String countdown;
//   const FlashCountdownRow({super.key, required this.countdown});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 1,
//           child: Image.asset(
//             "assets/figmaIcons/62-[Converted] 1.png",
//             fit: BoxFit.contain,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           flex: 1,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "Hurry!! Countdown starts",
//                 style: Styles.textSmall(context, color: Colors.white),
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 1,
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.orange,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     countdown,
//                     style: Styles.textSmall(context, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
