import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirebaseNotification {
  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);
    await _setupAwesomeNotifications();
  }
  static Future<void> _setupAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      'resource://mipmap/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'BiryaniPalyamApp',
          channelName: 'Biryani Palyam Notifications',
          channelDescription: 'Notification channel for Biryani Palyam app',
          defaultColor: const Color(0xFFFE724C),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          playSound: true,
          enableLights: true,
          enableVibration: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'BiryaniPalyamGroup',
          channelGroupName: 'App Notifications',
        ),
      ],
      debug: kDebugMode,
    );

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
   // log('Handling a background message ${message.messageId}');
    if (message.notification != null) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: message.hashCode,
          channelKey: 'BiryaniPalyamApp',
          title: message.notification!.title,
          body: message.notification!.body,
          notificationLayout: NotificationLayout.Default, // ✅ Clean layout
          largeIcon: 'resource://mipmap/ic_launcher', // ✅ Show logo in notification
          summary: 'BiryaniPalyam App',
        ),
      );
    }
  }
}