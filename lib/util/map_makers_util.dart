import 'dart:typed_data';
import 'dart:ui'as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createCustomMarker(
  String text, {
  bool isSelected = false,
}) async {
  const double width = 140;
  const double height = 80; // enough for bubble + pin

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  // Colors
  final Color bgColor = isSelected ? Colors.black : Colors.red;
  final Color borderColor = isSelected ? Colors.black : Colors.red;
  final Color textColor = isSelected ? Colors.white   : Colors.white;

  // 🔹 Bubble (rounded rectangle above pin)
  final RRect bubble = RRect.fromLTRBR(
    0,
    0,
    width,
    height - 25,
    const Radius.circular(12),
  );

  final Paint fillPaint = Paint()..color = bgColor;
  final Paint borderPaint = Paint()
    ..color = borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  canvas.drawRRect(bubble, fillPaint);
  canvas.drawRRect(bubble, borderPaint);

  // 🔹 Pin triangle pointer
  final Path triangle = Path()
    ..moveTo(width / 2 - 12, height - 25)
    ..lineTo(width / 2 + 12, height - 25)
    ..lineTo(width / 2, height)
    ..close();

  canvas.drawPath(triangle, fillPaint);
  canvas.drawPath(triangle, borderPaint);

  // 🔹 Centered text inside bubble
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: textColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout(maxWidth: width - 20);

  final double offsetX = (width - textPainter.width) / 2;
  final double offsetY = ((height - 25) - textPainter.height) / 2;

  textPainter.paint(canvas, Offset(offsetX, offsetY));

  // ✅ Convert to image
  final ui.Image img =
      await recorder.endRecording().toImage(width.toInt(), height.toInt());
  final ByteData? byteData =
      await img.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List bytes = byteData!.buffer.asUint8List();

  return BitmapDescriptor.bytes(bytes);
}
