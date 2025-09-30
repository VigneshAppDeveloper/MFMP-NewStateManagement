import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_food_my_price/Providers/register_provider.dart';
import 'package:my_food_my_price/pages/Map/location_search_page.dart';
import 'package:my_food_my_price/pages/OrdersHistory/order_history.dart';
import 'package:my_food_my_price/pages/Profile%20Settings/about_page.dart';
import 'package:my_food_my_price/pages/Profile%20Settings/app_settings.dart';
import 'package:my_food_my_price/pages/Profile%20Settings/delete_account.dart';
import 'package:my_food_my_price/pages/Profile%20Settings/profile_edit.dart';
import 'package:my_food_my_price/pages/Profile%20Settings/rewards.dart';
import 'package:my_food_my_price/pages/Profile%20Settings/settings_page.dart';
import 'package:my_food_my_price/pages/app_guide.dart';
import 'package:my_food_my_price/pages/app_pages.dart';
import 'package:my_food_my_price/pages/intro_page.dart';
import 'package:my_food_my_price/pages/login.dart';
import 'package:my_food_my_price/pages/menu_page.dart';
import 'package:my_food_my_price/pages/otp.dart';
import 'package:my_food_my_price/pages/policy/contact_us.dart';
import 'package:my_food_my_price/pages/policy/privacy_policy.dart';
import 'package:my_food_my_price/pages/policy/refund_policy.dart';
import 'package:my_food_my_price/pages/policy/shipping_policy.dart';
import 'package:my_food_my_price/pages/register.dart';
import 'package:my_food_my_price/util/extension.dart';
import 'package:provider/provider.dart';

import 'models/Resturant Model/resturant.dart';

enum AppRouteName {
  splashPage('/splash_page'),
  login('/login'),
  otp('/otp'),
  appPage('/app_pages'),
  introPage('/intro_page'),
  registerPage('/register'),
  homePage('/otp'),
  serachLocation('/location_search_page.dart'),
  editProfilePage('/profile_edit'),
  aboutPage('/about_page'),
  contactUs('/contact_us'),
  privacyPolicy('/privacy_policy'),
  refundPOlicy('/refund_policy'),
  shippingPolicy('/shipping_policy'),
  appGuide('/app_guide'),
  settingsPage('/settings_page'),
  deleteAccount('/delete_account'),
  rewards('/rewards'),
  menuPage('/menu_page'),
  orderHistoryPage('/order_history'),
  appSettingsPage('/app_settings');

  /// args: TaskViewScreenArgs

  final String value;
  const AppRouteName(this.value);
}

extension AppRouteNameExt on AppRouteName {
  Future<T?> push<T extends Object?>(
    BuildContext context, {
    Object? args,
  }) async {
    return await Navigator.pushNamed<T>(context, value, arguments: args);
  }

  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context, {
    Object? args,
  }) async {
    return await Navigator.pushReplacementNamed<T, TO>(
      context,
      value,
      arguments: args,
    );
  }

  Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    bool Function(Route<dynamic>) predicate, {
    Object? args,
  }) async {
    return await Navigator.pushNamedAndRemoveUntil<T>(
      context,
      value,
      predicate,
      arguments: args,
    );
  }

  Future<T?> popAndPush<T extends Object?>(
    BuildContext context, {
    Object? args,
  }) async {
    return await Navigator.popAndPushNamed(context, value, arguments: args);
  }
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final name =
        AppRouteName.values
            .where((element) => element.value == settings.name)
            .firstOrNull;

    switch (name) {
      // case AppRouteName.splashPage:
      //   return MaterialPageRoute(builder: (_) => Splash());
      case AppRouteName.login:
        return MaterialPageRoute(builder: (_) => Login());
      case AppRouteName.otp:
        return MaterialPageRoute(builder: (_) => Otp());
      case AppRouteName.introPage:
        return MaterialPageRoute(builder: (_) => IntroPage());
      case AppRouteName.appPage:
        return MaterialPageRoute(builder: (_) => AppPages());
      case AppRouteName.serachLocation:
  return MaterialPageRoute<LatLng>(
    builder: (_) => const LocationSearchPage(),
  );

      case AppRouteName.appSettingsPage:
        return MaterialPageRoute(builder: (_) => AppSettings());
      case AppRouteName.editProfilePage:
        return MaterialPageRoute(builder: (_) => ProfileEdit());
      case AppRouteName.aboutPage:
        return MaterialPageRoute(builder: (_) => AboutPage());
      case AppRouteName.contactUs:
        return MaterialPageRoute(builder: (_) => ContactUs());
      case AppRouteName.privacyPolicy:
        return MaterialPageRoute(builder: (_) => PrivacyPolicy());
      case AppRouteName.refundPOlicy:
        return MaterialPageRoute(builder: (_) => RefundPolicy());
      case AppRouteName.shippingPolicy:
        return MaterialPageRoute(builder: (_) => ShippingPolicy());
      case AppRouteName.appGuide:
        return MaterialPageRoute(builder: (_) => AppGuide());
      case AppRouteName.settingsPage:
        return MaterialPageRoute(builder: (_) => SettingsPage());
      case AppRouteName.deleteAccount:
        return MaterialPageRoute(builder: (_) => DeleteAccount());
      case AppRouteName.rewards:
        return MaterialPageRoute(builder: (_) => Rewards());
      case AppRouteName.orderHistoryPage:
        return MaterialPageRoute(builder: (_) => OrderHistory());
      case AppRouteName.menuPage:
        if (args is Map<String, dynamic>) {
          final restaurant = args['restaurant'] as Restaurant;
          final showPriceTabs = args['showPriceTabs'] as bool? ?? false;

          return MaterialPageRoute(
            builder:
                (_) => MenuPage(
                  restaurant: restaurant,
                  showPriceTabs: showPriceTabs,
                ),
          );
        }
        // fallback in case args are missing
        return MaterialPageRoute(
          builder:
              (_) => const SafeArea(
                child: Scaffold(body: Text("Invalid MenuPage arguments")),
              ),
        );

      case AppRouteName.registerPage:
        return MaterialPageRoute(
          builder:
              (_) => ChangeNotifierProvider(
                create: (_) => RegisterProvider(),
                child: const Register(),
              ),
        );

      case null:
        return MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: Text(
                  "Route Error",
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
              ),
            );
          },
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => const SafeArea(child: Scaffold(body: Text("Route Error"))),
        );
    }
  }
}
