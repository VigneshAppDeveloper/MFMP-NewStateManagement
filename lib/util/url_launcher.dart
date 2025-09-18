import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  static Future<void> launchInBrowser(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      final bool canLaunch = await canLaunchUrl(uri);
      
      if (!canLaunch) {
        throw Exception('No handler for URL');
      }

      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault, // More compatible
      );

      if (!launched) {
        throw Exception('Failed to launch URL');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not launch the URL',
            textScaler: TextScaler.linear(1.0),
          ),
        ),
      );
    }
  }
}
