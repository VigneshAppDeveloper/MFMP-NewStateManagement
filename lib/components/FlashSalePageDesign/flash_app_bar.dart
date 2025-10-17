import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

import '../../Providers/location_provider.dart';
import '../../Providers/restaurant_provider.dart';
import '../../models/LocationModels/location_model.dart';
import '../../route_generator.dart';
import '../../services/location_service.dart';
import '../../services/secure_storage.dart';
import '../../util/app_contant.dart';
import '../HomePageDesigns/home_search_bar.dart';

class FlashAppBar extends StatefulWidget {
  final String countdown;
  final TextEditingController searchController;
  const FlashAppBar({
    super.key,
    required this.countdown,
    required this.searchController,
  });

  @override
  State<FlashAppBar> createState() => _FlashAppBarState();
}

class _FlashAppBarState extends State<FlashAppBar> {
  String mainAddressLine = '';
  String subAddressLine = '';

  @override
  void initState() {
    super.initState();
    loadAddressFromStorage();
  }

  Future<void> loadAddressFromStorage() async {
    final locationJson = await SecureStorageService.read(AppConstants.location);
    if (locationJson != null) {
      final location = LocationModel.fromJson(json.decode(locationJson));
      setState(() {
        mainAddressLine =
            location.areaName.isNotEmpty
                ? location.areaName
                : location.district;
        subAddressLine = location.address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SliverAppBar(
      automaticallyImplyLeading: false,
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      backgroundColor: Colors.transparent,

      // ✅ use expandedHeight instead of toolbarHeight
      expandedHeight: MediaQuery.of(context).size.height * 0.30,

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.03,
            vertical: MediaQuery.of(context).size.height * 0.015,
          ),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg/flashsalebg.png"),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),

          child: SafeArea(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // ✅ Column only takes needed height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔻 Top row
                Consumer<LocationProvider>(
                  builder: (context, provider, _) {
                    final location = provider.currentLocation;

                    final mainAddressLine =
                        location == null
                            ? "Loading..."
                            : (location.areaName.isNotEmpty
                                ? location.areaName
                                : location.district);
                    final subAddressLine =
                        location?.address ?? "Fetching address...";

                    return Row(
                      children: [
                        // 🔻 Address section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final result = await AppRouteName
                                      .serachLocation
                                      .push<LatLng>(context);
                                  if (result != null && context.mounted) {
                                    // 1. Update restaurants
                                    context
                                        .read<RestaurantProvider>()
                                        .getRestaurants(
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
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        mainAddressLine,
                                        style: Styles.textStyleMedium(
                                          context,
                                        ).copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        textScaler: const TextScaler.linear(
                                          1.0,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 20,
                                    ),
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
                        Image.asset('assets/icons/reward.gif', height: 30),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            AppConstants.profile?.wallet ?? '0',
                            style: Styles.textSmall(context).copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
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
                            child: Icon(
                              Icons.person_outline,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.015),

                // 🔻 Search bar
                HomeSearchBar(
                  controller: widget.searchController,
                  onFilterTap: () {},
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.015),

                // 🔻 Flash Sale Row
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Image.asset(
                        "assets/icons/saleoffer.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Hurry!! Countdown starts",
                            style: Styles.textSmall(
                              context,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.countdown,
                                style: Styles.textSmall(
                                  context,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
