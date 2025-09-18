import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/Providers/login_provider.dart';
import 'package:my_food_my_price/Providers/restaurant_provider.dart';
import 'package:my_food_my_price/config/app_theme.dart';
import 'package:my_food_my_price/flavours.dart';
import 'package:my_food_my_price/pages/spalsh_page.dart';
import 'package:my_food_my_price/route_generator.dart' show RouteGenerator;
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:provider/provider.dart';

ValueNotifier<bool> isDevicePreviewEnabled = ValueNotifier<bool>(false);
bool testingMode = kDebugMode && F.appFlavor == Flavor.dev;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkNotificationPermission();
    });
  }

  Future<void> checkNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!mounted) return; // ✅ check if widget is still active

    if (!isAllowed) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Notifications'),
          content: const Text(
            'Notifications are essential for the full functionality of our app. Please enable them to continue.',
          ),
          actions: [
            TextButton(
              child: const Text('Allow Notifications'),
              onPressed: () {
                Navigator.of(context).pop();
                AwesomeNotifications().requestPermissionToSendNotifications();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDevicePreviewEnabled,
      builder: (context, value, __) {
        return AppThemeData(
          data: AppThemes(ThemeMode.light).customTheme,
          child: DevicePreview(
            enabled: F.appFlavor != Flavor.prod ? value : false,
            builder: (context) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (ctx) => LoginProvider()),
                  ChangeNotifierProvider(create: (_) => RestaurantProvider()),
                ],
                child: MaterialApp(
                  localizationsDelegates: const [],
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: MediaQuery.of(context).textScaler.clamp(
                          minScaleFactor: 0.5,
                          maxScaleFactor: 1.5,
                        ),
                      ),
                      child: child!,
                    );
                  },
                  navigatorKey: AppConstants.navigatorKey,
                  //useInheritedMediaQuery: true,
                  onGenerateRoute: RouteGenerator.generateRoute,
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  theme: AppThemes(ThemeMode.light).theme,
                  darkTheme: AppThemes(ThemeMode.dark).theme,
                  themeMode: ThemeMode.light,
                  home: const Splash(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}