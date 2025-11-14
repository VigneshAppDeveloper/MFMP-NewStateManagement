import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_food_my_price/Gateway/phonepay.dart';
import 'package:my_food_my_price/config/firebase/firebase_config.dart';
import 'package:my_food_my_price/config/firebase/firebase_notification.dart';

import '../services/ntp_service.dart';
import '../services/secure_storage.dart';

class AppInitialize {
  static Future<void> start() async {
    if (kDebugMode) {
      HttpOverrides.global = MyHttpOverrides();
    }
    WidgetsFlutterBinding.ensureInitialized();
    await FirebaseConfig.initialize();
    await _setupCrashlytics();
    await FirebaseNotification.initialize();
    await PhonePeGateway.init();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // White status bar
        statusBarIconBrightness: Brightness.light, // Dark icons on status bar
        systemNavigationBarColor: Colors.white, // White bottom bar
        systemNavigationBarIconBrightness: Brightness.light, // Dark icons
      ),
    );
    await SecureStorageService.saveGoogleApiKey(
      "AIzaSyC1q5b6YQz6m_uBeE8r8R3jsK0gAdlePz0", // replace with your actual key
    );
    final ntp = NtpService();
    await ntp.initialize();

    // Optionally fetch once at startup for warm cache
    await ntp.getCurrentIST(forceRefresh: true);
  }

  static Future<void> _setupCrashlytics() async {
    // ✅ Enable collection (disable automatically if needed for debug)
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

    // ✅ Capture all Flutter framework errors
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // ✅ Capture all unhandled async / platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // ✅ Optional custom log to verify setup
    FirebaseCrashlytics.instance.log("Crashlytics initialized successfully");
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
