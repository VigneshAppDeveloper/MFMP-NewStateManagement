import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:my_food_my_price/Providers/login_provider.dart';

import 'package:my_food_my_price/components/update_popup.dart';
import 'package:my_food_my_price/models/app_state_model.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/services/location_service.dart';
import 'package:my_food_my_price/services/secure_storage.dart';
import 'package:my_food_my_price/util/constant_image.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:provider/provider.dart';

import '../Providers/location_provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final newVersion = NewVersionPlus(
    androidId: 'com.biryanipalayam.myfoodmyprice',
    iOSId: '6744266788',
  );
  @override
  void initState() {
    super.initState();
    getconnectStatus();
  }

  void _checkVersion() async {
    final status = await newVersion.getVersionStatus();
    if (status != null && status.canUpdate) {
      _showForceUpdateDialog(status.appStoreLink);
    } else {
      _proceedToNextScreen();
    }
  }

  Future _getData() async {
    await context.read<LoginProvider>().initialFetch();
    await context.read<LocationProvider>().loadGpsLocation(); 
  }

  void _proceedToNextScreen() async {
    Timer(Duration(seconds: 2), () async {
      if (!mounted) return; // ✅ ADD THIS LINE SAFETY CHECK
      final appState = await SecureStorageService.getUserAppState();

      if (appState.isLoggedIn) {
        try {
          await context
              .read<LoginProvider>()
              .getProfile(); // ✅ Load profile once
        } catch (e) {
          debugPrint("❌ Error loading profile: $e");
        }
      }

      navigate(appState);
    });
  }

  void navigate(AppStateModel state) {
    if (!mounted) return;

    if (state.isLoggedIn) {
      // ✅ User is logged in → go to main app page
      AppRouteName.appPage.pushAndRemoveUntil(context, (route) => false);
    } else {
      // ✅ User is NOT logged in → go to login page
      AppRouteName.login.pushAndRemoveUntil(context, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ConstantImageKey.splashImage),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _showForceUpdateDialog(String updateUrl) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force update
      builder:
          (context) => UpdatePopup(
            yes: () {
              NewVersionPlus().launchAppStore(updateUrl);
            },
            no: () {
              exit(0);
            },
          ),
    );
  }

  void getconnectStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showalert();
    } else {
      await _getData();
      _checkVersion();
    }
  }

  _showalert() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Network Status',
              style: Styles.textStyleMedium(context),
              textScaler: TextScaler.linear(1.0),
            ),
            content: Text(
              'You are not connect with internet',
              style: Styles.textStyleMedium(context),
              textScaler: TextScaler.linear(1.0),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Ok',
                  style: Styles.textStyleMedium(context),
                  textScaler: TextScaler.linear(1.0),
                ),
              ),
            ],
          ),
    );
  }
}
