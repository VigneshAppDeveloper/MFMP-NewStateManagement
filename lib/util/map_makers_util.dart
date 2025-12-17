import 'dart:async';
import 'dart:typed_data';
import 'dart:ui'as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createCustomMarker(
  String text, {
  bool isSelected = false,
}) async {
  const double width = 140;
  const double height = 65;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  // ====== COLORS ======
  // Unselected
  final Color unselectedFill = const Color(0xFFFEF1CE).withOpacity(0.46);
  final Color unselectedStroke = const Color(0xFFFF0000).withOpacity(0.46);

  // Selected → Full dark red
  final Color selectedFill = const Color(0xFFFF0000); // solid red
  final Color selectedStroke = const Color(0xFFFF0000); // darker red border
  // =====================

  final Color bubbleColor = isSelected ? selectedFill : unselectedFill;
  final Color borderColor = isSelected ? selectedStroke : unselectedStroke;

  // Text Colors
  final Color textColor =
      isSelected ? Colors.white : const Color(0xFF1A1A1A); // stronger dark text

  // ---------- Bubble ----------
  final RRect bubble = RRect.fromLTRBR(
    0,
    0,
    width,
    height - 25,
    const Radius.circular(18),
  );

  final Paint fillPaint = Paint()..color = bubbleColor;

  final Paint borderPaint = Paint()
    ..color = borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = isSelected ? 0.8 : 0.8; // crisp edge

  canvas.drawRRect(bubble, fillPaint);
  canvas.drawRRect(bubble, borderPaint);

  // ---------- Pin Triangle ----------
  final Path triangle = Path()
    ..moveTo(width / 2 - 10, height - 25)
    ..lineTo(width / 2 + 10, height - 25)
    ..lineTo(width / 2, height)
    ..close();

  canvas.drawPath(triangle, fillPaint);
  canvas.drawPath(triangle, borderPaint);

  // ----------- Text (1 line, ellipsis) -----------
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: text.trim(),
      style: TextStyle(
        color: textColor,
        fontSize: 13,                // slightly increased brightness & size
        fontWeight:
            isSelected ? FontWeight.w700 : FontWeight.w600, // stronger bold
      ),
    ),
    maxLines: 1,
    ellipsis: '…',
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  textPainter.layout(maxWidth: width - 24);

  final double offsetX = (width - textPainter.width) / 2;
  final double offsetY = ((height - 25) - textPainter.height) / 2;

  textPainter.paint(canvas, Offset(offsetX, offsetY));

  // Convert to image
  final ui.Image img =
      await recorder.endRecording().toImage(width.toInt(), height.toInt());
  final ByteData? byteData =
      await img.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
}


Future<BitmapDescriptor> createImageMarker({
  required String imageUrl,
  bool isSelected = false,
}) async {
  const double size = 50;
  const double imageSize = 30;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  final Paint circleBorder = Paint()
    ..color = isSelected ? Colors.black : Colors.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = isSelected ? 6 : 4;

  final Paint circleFill = Paint()..color = Colors.white;

  // Draw outer border
  canvas.drawCircle(
    Offset(size / 2, size / 2),
    size / 2,
    circleBorder,
  );

  // Draw inner white circle
  canvas.drawCircle(
    Offset(size / 2, size / 2),
    (size / 2) - 4,
    circleFill,
  );

  // ---- Load Image ----
  final Completer<ui.Image> completer = Completer();
  final img = NetworkImage(imageUrl);
  img.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener((info, _) => completer.complete(info.image)),
  );

  final ui.Image networkImage = await completer.future;
  final ui.Rect src = Rect.fromLTWH(
    0,
    0,
    networkImage.width.toDouble(),
    networkImage.height.toDouble(),
  );

  final ui.Rect dst = Rect.fromCircle(
    center: Offset(size / 2, size / 2),
    radius: imageSize / 2,
  );

  canvas.clipPath(Path()..addOval(dst));

  // Draw the image
  canvas.drawImageRect(networkImage, src, dst, Paint());

  final ui.Image markerAsImage =
      await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final ByteData? byteData =
      await markerAsImage.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
}


Future<BitmapDescriptor> createFinalMarker(Uint8List thumbBytes) async {
  const double size = 70;
  const double imgSize = 52;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final Offset center = Offset(size / 2, size / 2);

  final borderPaint = Paint()
    ..color = Colors.red
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;

  final fillPaint = Paint()..color = Colors.white;

  canvas.drawCircle(center, size / 2, fillPaint);
  canvas.drawCircle(center, size / 2, borderPaint);

  final codec = await ui.instantiateImageCodec(thumbBytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;

  final dst = Rect.fromCircle(center: center, radius: imgSize / 2);

  canvas.save();
  canvas.clipPath(Path()..addOval(dst));
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    dst,
    Paint(),
  );
  canvas.restore();

  final img = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
}
