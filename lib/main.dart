import 'package:flutter/material.dart';
import 'package:my_food_my_price/app.dart';
import 'package:my_food_my_price/config/app_initialize.dart';

Future<void> main() async {
  await AppInitialize.start();
  runApp(MyApp());
}