import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  static const double baseWidth = 375;

  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    return baseFontSize * (screenWidth / baseWidth);
  }

  static TextStyle customTextStyle(
    BuildContext context,
    double fontSize, {
    FontWeight fontWeight = FontWeight.w400,
    Color color = Colors.black,
  }) {
    return GoogleFonts.inter(
      color: color,
      fontWeight: fontWeight,
      fontSize: responsiveFontSize(context, fontSize),
    );
  }

  static TextStyle textExtraSmall(
    BuildContext context, {
    Color color = Colors.black,
  }) => customTextStyle(context, 10, color: color);

  static TextStyle textSmall(
    BuildContext context, {
    Color color = Colors.black,
  }) => customTextStyle(context, 13, color: color);

  static TextStyle textStyleMedium(
    BuildContext context, {
    Color color = Colors.black,
  }) => customTextStyle(context, 14, fontWeight: FontWeight.w500, color: color);

  static TextStyle textStyleMediumBold(
    BuildContext context, {
    Color color = Colors.black,
  }) {
    return GoogleFonts.dmSans(
      color: color,
      fontWeight: FontWeight.w600,
      fontSize: responsiveFontSize(context, 14),
    );
  }

  static TextStyle textStyleLarge(
    BuildContext context, {
    Color color = Colors.black,
  }) => customTextStyle(context, 16, fontWeight: FontWeight.w700, color: color);

  static TextStyle textStyleExtraLarge(
    BuildContext context, {
    Color color = Colors.black,
  }) => customTextStyle(context, 20, fontWeight: FontWeight.w700, color: color);

  static TextStyle textExtraLargeBold(
    BuildContext context, {
    Color color = Colors.black,
  }) => customTextStyle(context, 22, fontWeight: FontWeight.bold, color: color);

  static TextStyle textHugeBold(
    BuildContext context, {
    Color color = Colors.black,
  }) => customTextStyle(context, 25, fontWeight: FontWeight.bold, color: color);

  static TextStyle textExtraHugeBold(
    BuildContext context, {
    Color color = Colors.black,
  }) => customTextStyle(context, 30, fontWeight: FontWeight.bold, color: color);

  static TextStyle textAnimation(
    BuildContext context, {
    Color color = Colors.black,
  }) => customTextStyle(context, 45, fontWeight: FontWeight.w500, color: color);
}
