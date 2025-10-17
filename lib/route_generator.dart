import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_food_my_price/Providers/bidding_provider.dart';
import 'package:my_food_my_price/Providers/register_provider.dart';
import 'package:my_food_my_price/pages/FixedPayment/Widgets/Screens/fixed_failure.dart';
import 'package:my_food_my_price/pages/FixedPayment/Widgets/Screens/fixed_sucess.dart';
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
import 'package:my_food_my_price/pages/bidding_page.dart';
import 'package:my_food_my_price/pages/FixedPayment/fixed_price_payment_page.dart';
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

import 'Providers/bidding_order_provider.dart';
import 'Providers/fixed_order_provider.dart';
import 'Providers/order_history_provider.dart';
import 'models/BidderModels/winner_model.dart';
import 'models/FoodModels/resturant_menu_model.dart';
import 'models/Resturant Model/resturant.dart';
import 'pages/BiddinPayment/Screens/bid_failure.dart';
import 'pages/BiddinPayment/Screens/bid_success.dart';
import 'pages/BiddinPayment/bidding_payment_page.dart';
import 'pages/Ratings/ratings_page.dart';

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
  fixedPricePayment('/fixed_price_payment_page'),
  biddingPage('/bidding_page'),
  biddingPaymentPage('/bidding_payment_page'),
  biddingPaymentSuccessPage('/bid_success'),
  biddingPaymentFailedPage('/bid_failure'),
  fixedPricePaymentSuccessPage('/fixed_success'),
  fixedPricePaymentFailedPage('/fixed_failure'),
  ratingsPage('/ratings_page'),
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
        final args = settings.arguments as Map<String, dynamic>?;
        final initialTab = args?['initialTab'] ?? 0;
        return MaterialPageRoute(
          builder: (_) => AppPages(initialTab: initialTab),
        );

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
        final args = settings.arguments as Map<String, dynamic>?;
        final initialTab = args?['initialTab'] ?? 0;
        final forceRefresh = args?['forceRefresh'] ?? false;

        return MaterialPageRoute(
          builder:
              (_) => OrderHistory(
                initialTab: initialTab,
                forceRefresh: forceRefresh,
              ),
        );

      case AppRouteName.biddingPage:
        if (args is Map<String, dynamic>) {
          final restaurant = args['restaurant'] as Restaurant;
          final timerId = args['timer_id'] as String;

          // 🧩 Safely handle both String and DateTime inputs
          final rawStart = args['slot_start'];
          final rawEnd = args['slot_end'];

          DateTime _safeParse(dynamic value) {
            if (value is DateTime) return value;
            if (value is String && value.contains(':')) {
              try {
                final parts = value.split(':');
                final now = DateTime.now();
                final h = int.parse(parts[0]);
                final m = int.parse(parts[1]);
                final s = parts.length > 2 ? int.parse(parts[2]) : 0;
                return DateTime(now.year, now.month, now.day, h, m, s);
              } catch (_) {}
            }
            return DateTime.now();
          }

          final slotStart = _safeParse(rawStart);
          final slotEnd = _safeParse(rawEnd);

          return MaterialPageRoute(
            builder:
                (_) => ChangeNotifierProvider(
                  create: (_) => BiddingProvider(),
                  child: BiddingPage(
                    restaurant: restaurant,
                    timerId: timerId,
                    slotStart: slotStart,
                    slotEnd: slotEnd,
                  ),
                ),
          );
        }

        return MaterialPageRoute(
          builder:
              (_) => const SafeArea(
                child: Scaffold(
                  body: Center(child: Text("Invalid BiddingPage arguments")),
                ),
              ),
        );
      case AppRouteName.biddingPaymentPage:
        if (args is Map<String, dynamic>) {
          final winners = args['winners'] as List<WinnerModel>;
          final pickupDate = args['pickup_date'] as String;
          final pickupPoint = args['pickup_point'] as String;
          final restaurant = args['restaurant'] as Restaurant; // ✅ add this

          return MaterialPageRoute(
            builder:
                (_) => ChangeNotifierProvider(
                  create: (_) => BiddingOrderProvider(),
                  child: BiddingPaymentPage(
                    winners: winners,
                    pickupDate: pickupDate,
                    pickupPoint: pickupPoint,
                    restaurant: restaurant, // ✅ pass it here
                  ),
                ),
          );
        }

        return MaterialPageRoute(
          builder:
              (_) => const SafeArea(
                child: Scaffold(
                  body: Center(
                    child: Text("Invalid Bidding Payment arguments"),
                  ),
                ),
              ),
        );

      case AppRouteName.fixedPricePayment:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder:
                (_) => ChangeNotifierProvider(
                  create: (_) => FixedOrderProvider(),
                  child: FixedPricePaymentPage(
                    menus: args["menus"],
                    pickupDate: args["pickup_date"],
                    pickupPoint: args["pickup_point"],
                    restaurant: args["restaurant"],
                     fromFlashPage: args["from_flash"] ?? false, 
                  ),
                ),
          );
        }
        return MaterialPageRoute(
          builder:
              (_) => const SafeArea(
                child: Scaffold(
                  body: Center(child: Text("Invalid Fixed Payment arguments")),
                ),
              ),
        );

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
      case AppRouteName.biddingPaymentSuccessPage:
        return MaterialPageRoute(builder: (_) => const BidSuccessScreen());
      case AppRouteName.biddingPaymentFailedPage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => BidFailureScreen(
                winners: args['winners'],
                franchiseId: args['franchiseId'],
                timerId: args['timerId'],
              ),
        );

      case AppRouteName.ratingsPage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => RatingsPage(
                franchiseName: args["franchiseName"],
                menuCategoryNames: List<String>.from(args["menuCategoryNames"]),
                menuCategoryIds: List<String>.from(args["menuCategoryIds"]),
                orderIds: List<String>.from(args["orderIds"]),
                location: args["location"],
                franchiseImage: args["franchiseImage"],
                franchiseId: args["franchiseId"],
                orderType: args["orderType"],
              ),
        );
      case AppRouteName.fixedPricePaymentSuccessPage:
        return MaterialPageRoute(builder: (_) => const FixedSuccessScreen());
      case AppRouteName.fixedPricePaymentFailedPage:
        return MaterialPageRoute(builder: (_) => const FixedFailureScreen());
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
