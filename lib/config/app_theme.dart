import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_food_my_price/util/app_dimension.dart' show AppDimensions;
import 'package:my_food_my_price/util/color_constant.dart';

class AppThemes {
  final ThemeMode themeMode;
  CustomAppTheme get customTheme => CustomAppTheme(
      colorScheme: AppColor.customColorScheme, brightness: brightness);
  Brightness get brightness =>
      themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
  ColorScheme get colorScheme => themeMode == ThemeMode.dark
      ? AppColor.darkColorScheme
      : AppColor.colorScheme;
  ThemeData get theme => ThemeData(
        disabledColor: const Color(0xffE9E9E9),
        brightness: brightness,
        fontFamily: GoogleFonts.poppins().fontFamily,
        // bottomSheetTheme:
        //     BottomSheetThemeData(backgroundColor: AppColor.colorScheme.background),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                textStyle: const TextStyle(
                    fontSize: 18,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w500),
                side: BorderSide(
                  width: 1,
                  color: colorScheme.primary,
                ))),
        colorScheme: colorScheme,
        dialogTheme: DialogThemeData(
          backgroundColor: colorScheme.surface,
          // surfaceTintColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius)),
          actionsPadding: const EdgeInsets.all(AppDimensions.basicPadding),
        ),
        listTileTheme: ListTileThemeData(
          tileColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius)),
        ),
        textTheme: const TextTheme(
          bodySmall: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          bodyMedium: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          bodyLarge: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
          // titleLarge: TextStyle(fontWeight: FontWeight.bold),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
          headlineSmall: TextStyle(
            // color: color,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
          headlineMedium: TextStyle(
            // color: color,
            fontWeight: FontWeight.w600,
            fontSize: 26,
          ),
          headlineLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
          labelSmall: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          labelMedium: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          labelLarge: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        // fontFamily : GoogleFonts.poppins().fontFamily,
        // scaffoldBackgroundColor: const Color(0xFFE6E6E6),
        dividerTheme: const DividerThemeData(thickness: .4),
        // dividerColor: const Color(0xFFDBDBDB),
        appBarTheme: AppBarTheme(
            foregroundColor: colorScheme.onPrimary,
            backgroundColor: colorScheme.primary,
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            )),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: colorScheme.primaryContainer,
        ),
        cardColor: colorScheme.onPrimary,
        cardTheme: CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 3,
          color: colorScheme.onPrimary,
        ),
        hintColor: const Color(0xFF757575),
        inputDecorationTheme: InputDecorationTheme(
          prefixIconColor: const Color(0xFFDBDBDB),
          filled: true,
          isDense: true,
          fillColor: const Color(0xFFFFFFFF),
          suffixIconColor: const Color(0xffA8ACB9),
          hintStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.textFieldRadius),
            borderSide: BorderSide(color: colorScheme.outline, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.textFieldRadius),
            borderSide: BorderSide(color: colorScheme.outline, width: 0.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.textFieldRadius),
            borderSide: const BorderSide(color: Colors.transparent, width: 0.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.textFieldRadius),
            borderSide: BorderSide(color: colorScheme.primary, width: 0.8),
          ),
          // disabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(AppDimensions.textFieldRadius),
          //   borderSide:  BorderSide(color: colorScheme.outline, width: 0.5),
          // ),
          // errorBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(AppDimensions.textFieldRadius),
          //   borderSide:  BorderSide(color: colorScheme.outline, width: 0.5),
          // ),
          // focusedErrorBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(AppDimensions.textFieldRadius),
          //   borderSide:  BorderSide(color: colorScheme.outline, width: 0.5),
          // ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                foregroundColor: colorScheme.onPrimary,
                backgroundColor: colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)))),
      );

  static TextTheme textTheme = const TextTheme(
      labelMedium: TextStyle(
    fontSize: 16,
  ));

  AppThemes(this.themeMode);
}

class CustomAppTheme {
  final Brightness brightness;
  final AppColorScheme colorScheme;
  const CustomAppTheme({
    this.brightness = Brightness.light,
    this.colorScheme = AppColor.customColorScheme,
  });
}

class AppThemeData extends InheritedWidget {
  final CustomAppTheme data;
  // final Brightness? brightness;

  const AppThemeData({super.key, required this.data, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  static CustomAppTheme of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppThemeData>()?.data ??
        CustomAppTheme(
          brightness: MediaQuery.of(context).platformBrightness,
        );
  }
}

class AppColorScheme {
  final Color successColor;
  final Color pendingColor;
  final Color onPendingColor;
  final Color yellowColor;
  final Color pinkColor;
  final Color blueColor;
  final Color redColor;

  const AppColorScheme({
    required this.successColor,
    required this.pendingColor,
    required this.onPendingColor,
    required this.yellowColor,
    required this.pinkColor,
    required this.blueColor,
    required this.redColor,
  });
}
