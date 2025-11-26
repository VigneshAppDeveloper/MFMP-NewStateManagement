import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_food_my_price/Providers/login_provider.dart';

import 'package:my_food_my_price/components/update_popup.dart';
import 'package:my_food_my_price/models/app_state_model.dart';
import 'package:my_food_my_price/route_generator.dart';
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
    FirebaseCrashlytics.instance.log("Splash started");
    getconnectStatus();
  }

  void _checkVersion() async {
    try {
      final status = await newVersion.getVersionStatus();
      if (status != null && status.canUpdate) {
        _showForceUpdateDialog(status.appStoreLink);
      } else {
        _proceedToNextScreen();
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: "Version check failed",
      );
    }
  }

  Future _getData() async {
    try {
      await context.read<LoginProvider>().initialFetch();
      await context.read<LocationProvider>().loadGpsLocation(context: context);

      final location = context.read<LocationProvider>().currentLocation;
      final permission = await Geolocator.checkPermission();

      if (location == null ||
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        AppRouteName.enableLocationPage.pushReplacement(context);
        return;
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: "Splash _getData failed",
      );
    }
  }

  void _proceedToNextScreen() async {
    FirebaseCrashlytics.instance.log("Proceeding to next screen");
    Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;

      AppStateModel appState;
      try {
        appState = await SecureStorageService.getUserAppState();
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(
          e,
          s,
          reason: "Splash getUserAppState failed",
        );
        await SecureStorageService.clearAllAppData();
        appState = AppStateModel(); // empty fallback
      }

      if (appState.token != null && appState.token!.isNotEmpty) {
        try {
          FirebaseCrashlytics.instance.log(
            "Fetching profile for logged-in user",
          );
          await context.read<LoginProvider>().getProfile();
        } catch (e, s) {
          FirebaseCrashlytics.instance.recordError(
            e,
            s,
            reason: "getProfile failed",
          );
        }
      }

      navigate(appState);
    });
  }

  void navigate(AppStateModel state) {
    // FirebaseCrashlytics.instance.log("Navigating — loggedIn: ${state.isLoggedIn}");
    if (!mounted) return;

    if (state.isLoggedIn) {
      AppRouteName.appPage.pushAndRemoveUntil(context, (_) => false);
    } else {
      AppRouteName.login.pushAndRemoveUntil(context, (_) => false);
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
