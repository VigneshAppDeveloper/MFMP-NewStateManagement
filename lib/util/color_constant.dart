import 'package:flutter/material.dart';
import 'package:my_food_my_price/config/app_theme.dart';

class AppColor {
  static const ColorScheme colorScheme = ColorScheme.light(
    // ignore: deprecated_member_use
    background: Color(0xFFFFFFFF),
    // ignore: deprecated_member_use
    onBackground: Color(0xFF050505),
    primary: Color(0xff2196F3),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFCAF1FC),
    onPrimaryContainer: Colors.white,
    secondary: Color(0xFF241E1E),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF041001),
    onSecondaryContainer: Color(0xFF757575),
    inversePrimary: Color(0xFF8FDAFF),
    outline: Color(0xffA8ACB9),
    outlineVariant: Color(0xFF757575),
    tertiary: Color(0xFFC4C4C4),
    onTertiary: Color(0xFFF3EBEB),
    error: Color(0xFFE50000),
    errorContainer: Color(0xffDC3545),
    onErrorContainer: Colors.white,
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF050505),
    surfaceTint: Color(0xFFFDFDFD),
    // ignore: deprecated_member_use
    surfaceVariant: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xFF000000),
    tertiaryContainer: Color(0xFF1E4066),
    onTertiaryContainer: Color(0xFFFFFFFF),
  );
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    // ignore: deprecated_member_use
    background: Color(0xFF121212),
    // ignore: deprecated_member_use
    onBackground: Color(0xFFE0E0E0),
    primary: Color(0xff2196F3),
    onPrimary: Color(0xFF000000),
    primaryContainer: Color(0xFF004F73),
    onPrimaryContainer: Color(0xFFB3ECFF),
    secondary: Color(0xFF241E1E),
    onSecondary: Color(0xFFE0E0E0),
    secondaryContainer: Color(0xFF3D3D3D),
    onSecondaryContainer: Color(0xFFB3B3B3),
    inversePrimary: Color(0xFF8FDAFF),
    outline: Color(0xFF6D6D6D),
    outlineVariant: Color(0xFFB3B3B3),
    tertiary: Color(0xFF666666),
    onTertiary: Color(0xFF1A1A1A),
    error: Color(0xFFCF6679),
    errorContainer: Color(0xFFB00020),
    onErrorContainer: Color(0xFFFFE5E5),
    surface: Color(0xFF1E1E1E),
    onSurface: Color(0xFFE0E0E0),
    surfaceTint: Color(0xFF121212),
    // ignore: deprecated_member_use
    surfaceVariant: Color(0xFF2C2C2C),
    onSurfaceVariant: Color(0xFFE0E0E0),
    tertiaryContainer: Color(0xFF1E4066),
    onTertiaryContainer: Color(0xFFE0F7FF),
  );
  static const AppColorScheme customColorScheme = AppColorScheme(
    successColor: Colors.green,
    pendingColor: Colors.orange,
    onPendingColor: Colors.white,
    yellowColor: Color(0xffFFC107),
    pinkColor: Color(0xffE91E63),
    blueColor: Color(0xff2196F3),
    redColor: Colors.red,
  );

  static const Color yellowColor = Color.fromARGB(255, 248, 186, 0);
  static const Color pinkColor = Color(0xffE91E63);
  static const Color blueColor = Color(0xff2196F3);
  static const Color hintTextColor = Color(0xff686868);
  static const Color whiteColor = Color(0xffFFFFFF);
  static const Color borderColor = Color(0xff000000);
  static const Color blackColor = Color(0xff000000);
  static const Color maincolor = Color.fromARGB(244, 240, 39, 4);
  static const Color backgroundColor = Color.fromARGB(255, 5, 185, 11);
  static const Color fillColor= Color.fromARGB(255, 97, 177, 5);
  static const List<List<Color>> upcomingCardGradientColor = [
    [
      Color(0xFF50252B),
      Color(0xFFD7B263),
    ],
    [
      Color(0xFFF47515),
      Color(0xFF1A64A5),
    ],
  ];
}