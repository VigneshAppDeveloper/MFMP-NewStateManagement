import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_food_my_price/config/firebase/firebase_config.dart';
import 'package:my_food_my_price/config/firebase/firebase_notification.dart';

import '../services/secure_storage.dart';

class AppInitialize {
  static Future<void> start() async {
    if (kDebugMode) {
      HttpOverrides.global = MyHttpOverrides();
    }
    WidgetsFlutterBinding.ensureInitialized();
    await FirebaseConfig.initialize();
    await FirebaseNotification.initialize();

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
