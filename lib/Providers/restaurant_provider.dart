import 'package:flutter/material.dart';

import '../models/FoodModels/food_model.dart';
import '../models/Resturant Model/banner_model.dart';
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

  List<Restaurant> _filteredRestaurants = [];
  List<Restaurant> get filteredRestaurants => _filteredRestaurants;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // -------------------- BANNERS --------------------
  List<BannerModel> _banners = [];
  List<BannerModel> get banners => _banners;

  bool _isBannerLoading = false;
  bool get isBannerLoading => _isBannerLoading;

  DateTime? _lastBannerFetch;
  final Duration _bannerCacheDuration = const Duration(minutes: 10);

  final Map<int, List<Restaurant>> _categoryCache = {};
  final Map<int, DateTime> _categoryCacheTime = {};
  final Duration _cacheDuration = const Duration(minutes: 10);

  void searchRestaurants(String query) {
    query = query.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredRestaurants = _restaurants;
      _isSearching = false;
    } else {
      _isSearching = true;
      _filteredRestaurants =
          _restaurants
              .where(
                (r) =>
                    r.name.toLowerCase().contains(query) ||
                    r.address.toLowerCase().contains(query),
              )
              .toList();
    }
    debugPrint("✅ Filtered count: ${_filteredRestaurants.length}");
    notifyListeners();
  }

  void clearSearch() {
    _filteredRestaurants = _restaurants;
    _isSearching = false;
    notifyListeners();
  }

  void setIsSearching(bool value) {
    if (_isSearching == value) return; // ✅ no redundant rebuild
    _isSearching = value;
    notifyListeners();
  }

  Future<void> getRestaurants({
    required double lat,
    required double lng,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url = "${UrlPath.restaurantUrl.getNearbyFranchise}/$lat/$lng";

    try {
      final resp = await APIService.get(url, auth: true);
      if (resp.status) {
        final List<dynamic> data = resp.data;
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

  Future<void> getBanners({bool forceRefresh = false}) async {
    // ✅ Use cached data if not expired
    final now = DateTime.now();
    if (!forceRefresh &&
        _banners.isNotEmpty &&
        _lastBannerFetch != null &&
        now.difference(_lastBannerFetch!) < _bannerCacheDuration) {
      debugPrint("⚡ Loaded banners from cache (${_banners.length})");
      return;
    }

    _isBannerLoading = true;
    notifyListeners();

    final url = UrlPath.restaurantUrl.getBanner;
    debugPrint("🚀 Fetching banners from: $url");

    try {
      final resp = await APIService.get(url, auth: true);
      debugPrint("📡 Banner RESPONSE BODY: ${resp.fullBody}");

      if (resp.status) {
        // ✅ Handle both {result: [...] } or direct list
        final data =
            resp.data is Map<String, dynamic>
                ? resp.data['result'] ?? []
                : (resp.data ?? []);

        _banners =
            (data as List)
                .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
                .toList();

        _lastBannerFetch = now;
        error = null;

        debugPrint("✅ Parsed ${_banners.length} banners");
      } else {
        error = resp.message ?? "Failed to fetch banners.";
        _banners = [];
      }
    } catch (e) {
      error = e.toString();
      _banners = [];
      debugPrint("❌ Error fetching banners: $e");
    }

    _isBannerLoading = false;
    notifyListeners();
  }

  Future<void> getRestaurantsByCategory({
  required double lat,
  required double lng,
  required int menuTypeId,
  bool forceRefresh = false,
}) async {
  final now = DateTime.now();

  // ✅ Check cache validity
  if (!forceRefresh &&
      _categoryCache.containsKey(menuTypeId) &&
      _categoryCacheTime.containsKey(menuTypeId) &&
      now.difference(_categoryCacheTime[menuTypeId]!) < _cacheDuration) {
    _restaurants = _categoryCache[menuTypeId]!;
    debugPrint("⚡ Loaded category $menuTypeId from cache (${_restaurants.length} items)");
    notifyListeners();
    return;
  }

  _isLoading = true;
  notifyListeners();

  final url = "${UrlPath.restaurantUrl.getNearbyFranchise}/$lat/$lng";
  debugPrint("🚀 Fetching Restaurants by Category: menuTypeId=$menuTypeId");

  try {
    final resp = await APIService.get(
      url,
      auth: true,
      params: {'menuTypeId': menuTypeId.toString()},
    );

    if (resp.status) {
      final List<dynamic> data = resp.data ?? [];
      final restaurants = data.map((e) => Restaurant.fromJson(e)).toList();

      _restaurants = restaurants;
      _categoryCache[menuTypeId] = restaurants;
      _categoryCacheTime[menuTypeId] = now;
      error = null;

      debugPrint("✅ Cached ${restaurants.length} restaurants for category $menuTypeId");
    } else {
      error = resp.message ?? "Failed to fetch restaurants.";
      _restaurants = [];
    }
  } catch (e) {
    error = e.toString();
    _restaurants = [];
    debugPrint("❌ Error fetching category restaurants: $e");
  }

  _isLoading = false;
  notifyListeners();
}

}
