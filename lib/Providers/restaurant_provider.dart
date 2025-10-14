import 'package:flutter/material.dart';

import '../models/FoodModels/food_model.dart';
import '../models/Resturant Model/resturant.dart';
import '../services/api_service.dart';
import '../util/url_path.dart';

class RestaurantProvider extends ChangeNotifier {
  List<Restaurant> _restaurants = [];
  List<Restaurant> get restaurants => _restaurants;


  List<FoodCategory> _categories = [];
  List<FoodCategory> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? error;

  Future<void> getRestaurants({
    required double lat,
    required double lng,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url = "${UrlPath.restaurantUrl.getNearbyFranchise}/$lat/$lng";

    try {
      final resp = await APIService.get(url, auth: true);
      debugPrint("📡 RESPONSE STATUS: ${resp.status}");
      debugPrint("📡 RAW DATA: ${resp.data}");

      if (resp.status) {
        final List<dynamic> data = resp.data; // ✅ already a List
        _restaurants = data.map((e) => Restaurant.fromJson(e)).toList();
        error = null;
      } else {
        error = resp.message ?? "Something went wrong.";
      }
    } catch (e) {
      error = e.toString();
      debugPrint("❌ Error fetching restaurants: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getFoodCategory() async {
  if (_categories.isNotEmpty) return;

  _isLoading = true;
  notifyListeners();

  final url = UrlPath.restaurantUrl.getFoodCategory;
  debugPrint("🚀 Fetching Food Categories from: $url"); // 👈 add this

  try {
    final resp = await APIService.get(url, auth: true);
    debugPrint("📡 FoodCategory RESPONSE BODY: ${resp.fullBody}");

    if (resp.status) {
      final List<dynamic> data = resp.data;
      _categories = data.map((e) => FoodCategory.fromJson(e)).toList();
      error = null;
    } else {
      error = resp.message ?? "Something went wrong.";
    }
  } catch (e) {
    error = e.toString();
    debugPrint("❌ Error fetching categories: $e");
  }

  _isLoading = false;
  notifyListeners();
}

}
