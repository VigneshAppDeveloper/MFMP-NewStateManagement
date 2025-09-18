import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Color textcolor;
  final double textsize;
  final FontWeight fontWeight;
  final double letterspacing;
  final double buttonwidth;
  final double buttonheight;
  final Color buttoncolor;
  final double radius;
  final VoidCallback onTap;

  const MyButton({
    super.key,
    required this.text,
    required this.textcolor,
    required this.textsize,
    required this.fontWeight,
    required this.letterspacing,
    required this.buttonwidth,
    required this.buttonheight,
    required this.buttoncolor,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonheight,
      width: buttonwidth,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttoncolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius), // ✅ use radius
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: FittedBox(
          child: Text(
            text,
            textAlign: TextAlign.center,
            textScaler: TextScaler.linear(1.0),
            style: GoogleFonts.poppins(
              decoration: TextDecoration.none,
              fontSize: textsize,
              fontWeight: fontWeight,
              letterSpacing: letterspacing,
              color: textcolor,
            ),
          ),
        ),
      ),
    );
  }
}
