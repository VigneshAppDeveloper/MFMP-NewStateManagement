import 'package:flutter/material.dart';

class FullScreenLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final Color backgroundColor;

  const FullScreenLoader({
    super.key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 3.0,
    this.backgroundColor = const Color(0x80000000), // semi-transparent black
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          dismissible: false,
          color: backgroundColor,
        ),
        Center(
          child: SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),

              strokeWidth: strokeWidth,
            ),
          ),
        ),
      ],
    );
  }
}
