import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_food_my_price/models/LocationModels/location_model.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/services/secure_storage.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/styles.dart';


class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  String mainAddressLine = '';
  String subAddressLine = '';

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadAddressFromStorage();
  }

  Future<void> loadAddressFromStorage() async {
    final locationJson = await SecureStorageService.read(AppConstants.location);
    if (locationJson != null) {
      final location = LocationModel.fromJson(json.decode(locationJson));
      setState(() {
        mainAddressLine = location.areaName.isNotEmpty
            ? location.areaName
            : location.district;
        subAddressLine = location.address;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 🔻 Address section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  AppRouteName.serachLocation.push(context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 22),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        mainAddressLine.isEmpty ? "Loading..." : mainAddressLine,
                        style: Styles.textStyleMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                subAddressLine.isEmpty ? "Fetching address..." : subAddressLine,
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
        Image.asset(
          'assets/icons/reward.gif',
          height: 30,
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
            child: Icon(Icons.person_outline, color: Colors.white),
          ),
        ),
      ],
    );
  }
}