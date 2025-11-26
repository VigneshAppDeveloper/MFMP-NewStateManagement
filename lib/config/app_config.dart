import 'package:my_food_my_price/flavours.dart';

class AppConfig {
  static const AppConfig instance = AppConfig();
  const AppConfig();

  String get baseUrl {
    switch (F.appFlavor) {
      case Flavor.prod:
        return 'https://myfoodmyprice.com/Applications/public/api/';
      case Flavor.dev:
        return 'https://myfoodmyprice.com/Applications/public/api/';
      case Flavor.demo:
        return 'https://mfmpdev.tsitcloud.com/tsit_biriyani_palayam-dev/public/api/';
      default:
        return 'https://myfoodmyprice.com/Applications/public/api/';
    }
  }


   String get storageBaseUrl {
    switch (F.appFlavor) {
      case Flavor.prod:
        return 'https://myfoodmyprice.com/Applications/storage/app/';
      case Flavor.dev:
        return 'https://mfmpdev.tsitcloud.com/tsit_biriyani_palayam-dev/storage/app/';
      case Flavor.demo:
        return 'https://tabsquareinfotech.com/App/Clients/biriyani_palayam/storage/app/';
      default:
        return 'https://myfoodmyprice.com/Applications/storage/app/';
    }
  }
 
  // Always use the production package name for PhonePe gateway
  String get gatewayPackageName => "com.biryanipalayam.myfoodmyprice";
}
