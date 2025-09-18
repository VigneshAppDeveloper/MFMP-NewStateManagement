import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBQd9QU4KjsJFEysWGyJGt5OVv2Y6wEWIg",
          appId: "1:388012489209:android:201d030a77a3c8d6cc6528",
          messagingSenderId: "388012489209",
          projectId: "myfoodmypricebiryanipalyam",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  }
}