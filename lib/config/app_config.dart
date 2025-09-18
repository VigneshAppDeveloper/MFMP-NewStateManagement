import 'package:my_food_my_price/flavours.dart';

class AppConfig {
  static const AppConfig instance = AppConfig();
  const AppConfig();

  String get baseUrl {
    switch (F.appFlavor) {
      case Flavor.prod:
        return 'https://mfmpdev.tsitcloud.com/tsit_biriyani_palayam-dev/public/api/';
      case Flavor.dev:
        return 'https://mfmpdev.tsitcloud.com/tsit_biriyani_palayam-dev/public/api/';
      case Flavor.demo:
        return 'https://tabsquareinfotech.com/App/Clients/biriyani_palayam/public/api/';
      default:
        return 'https://myfoodmyprice.com/Applications/public/api/';
    }
  }
 
  // Always use the production package name for PhonePe gateway
  String get gatewayPackageName => "com.biryanipalayam.myfoodmyprice";
}
