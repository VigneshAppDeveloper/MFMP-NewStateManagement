import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/app.dart';
import 'package:my_food_my_price/config/app_initialize.dart';

// Future<void> main() async {
//   await AppInitialize.start();
//  runZonedGuarded(() {
//     runApp(const MyApp());
//   }, (error, stack) {
//     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
//   });
// }

Future<void> main() async {
  // ✅ Wrap the entire initialization in the same zone
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize everything (Firebase, Crashlytics, etc.)
    await AppInitialize.start();

    // Run the app inside the SAME zone
    runApp(const MyApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}