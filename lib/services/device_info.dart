import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:my_food_my_price/models/devie_info_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoServices {
  static Future<String?> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    }
    return null;
  }

  static Future<String> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<DeviceInfoModel> getDeviceInfo() async {
    final String version = await _getVersion();
    final String imei = await _getDeviceId() ?? '';
    return DeviceInfoModel(imei: imei, version: version);
  }
}