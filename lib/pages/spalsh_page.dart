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
import 'package:package_info_plus/package_info_plus.dart';
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

  bool _isValidVersion(String v) {
    if (v.trim().isEmpty) return false;
    if (v == "0.0.0") return false;
    if (!RegExp(r'^\d+(\.\d+){1,3}$').hasMatch(v)) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    FirebaseCrashlytics.instance.log("Splash started");
    getconnectStatus();
  }

  Future<void> _checkVersion() async {

    String localName = "0.0.0";
    int localCode = 0;

    try {
      final pkg = await PackageInfo.fromPlatform();
      localName = pkg.version;
      localCode = int.tryParse(pkg.buildNumber) ?? 0;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: "PackageInfo failed",
      );
    }

    bool playStoreValid = false;
    String? storeVersion;

    try {
      final status = await newVersion.getVersionStatus();

      debugPrint("LOCAL VERSION : $localName");
      debugPrint("STORE VERSION : ${status?.storeVersion}");
      debugPrint("CAN UPDATE    : ${status?.canUpdate}");

      storeVersion = status?.storeVersion;

      // Validate Play Store data
      if (status != null &&
          storeVersion != null &&
          storeVersion != "0.0.0" &&
          _isValidVersion(storeVersion) &&
          _isValidVersion(localName)) {
        playStoreValid = true;

        if (status.canUpdate) {
          _showForceUpdateDialog(status.appStoreLink);
          return;
        }
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: "PlayStore version check failed",
      );
    }

    // If Play Store failed → fallback to API
    if (!playStoreValid) {
      final provider = context.read<LoginProvider>();
      bool apiResult = await provider.checkVersion(
        versionName: localName,
        versionCode: localCode,
      );
debugPrint("API VERSION CHECK RESULT: $apiResult");
      // apiResult = true → version OK
      // apiResult = false → mismatch → Force update
      if (!apiResult) {
        _showForceUpdateDialog(
          "https://play.google.com/store/apps/details?id=com.biryanipalayam.myfoodmyprice",
        );
        return;
      }
    }

    // Both checks passed → Continue
    _proceedToNextScreen();
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
     await _checkVersion();

  // 2️⃣ ONLY AFTER VERSION PASSED → PROCESS LOCATION / PROFILE
  await _getData();
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
