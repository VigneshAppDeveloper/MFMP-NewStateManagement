import 'dart:typed_data';
import 'dart:ui'as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createCustomMarker(String text, {bool isSelected = false}) async {
  const double width = 100; // increased width
  const double height = 60; // increased height for better spacing

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  final Color bgColor = isSelected ? Colors.white : Colors.black ;
  final Color borderColor = isSelected ? Colors.grey : Colors.transparent;
  final Color textColor = isSelected ? Colors.black : Colors.white;

  // Background with border
  final Paint paint = Paint()..color = bgColor;
  final Paint borderPaint = Paint()
    ..color = borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;

  final RRect bubble = RRect.fromLTRBR(
    0,
    0,
    width,
    height - 10,
    const Radius.circular(10),
  );

  canvas.drawRRect(bubble, paint);
  canvas.drawRRect(bubble, borderPaint);

  // Triangle pointer
  final Path triangle = Path()
    ..moveTo(width / 2 - 10, height - 10)
    ..lineTo(width / 2 + 10, height - 10)
    ..lineTo(width / 2, height)
    ..close();
  canvas.drawPath(triangle, paint);
  canvas.drawPath(triangle, borderPaint);

  // Draw centered text
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
    textScaler: TextScaler.linear(1.0),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout(maxWidth: width - 20);
  final offsetX = (width - textPainter.width) / 2;
  final offsetY = (height - 10 - textPainter.height) / 2;
  textPainter.paint(canvas, Offset(offsetX, offsetY));

  final ui.Image img = await recorder.endRecording().toImage(width.toInt(), height.toInt());
  final ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List bytes = byteData!.buffer.asUint8List();

  return BitmapDescriptor.bytes(bytes);
}
