import 'package:flutter/material.dart';

import '../models/FoodModels/food_model.dart';
import '../models/Resturant Model/banner_model.dart';
import '../models/Resturant Model/resturant.dart';
import '../services/api_service.dart';
import '../util/url_path.dart';

class RestaurantProvider extends ChangeNotifier {
  // ✅ Separate storage
  List<Restaurant> _restaurants = []; // normal restaurants
  List<Restaurant> _flashRestaurants = []; // flash-only restaurants

  List<Restaurant> get restaurants => _restaurants;
  List<Restaurant> get flashRestaurants => _flashRestaurants;

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

  String _scrollingText = '';
  String get scrollingText => _scrollingText;

  final Map<int, List<Restaurant>> _categoryCache = {};
  final Map<int, DateTime> _categoryCacheTime = {};
  final Duration _cacheDuration = const Duration(minutes: 10);

  List<Restaurant> _searchResults = [];
  List<Restaurant> get searchResults => _searchResults;

 bool _isPaginatingNormal = false;
  bool _isPaginatingFlash = false;

  bool get isPaginating => _isPaginatingNormal || _isPaginatingFlash;

  // -------------------- PAGINATION --------------------
  int _currentPageNormal = 1;
  int _lastPageNormal = 1;

  int _currentPageFlash = 1;
  int _lastPageFlash = 1;

  void clearSearchResults() {
    _searchResults = [];
  }


    Future<void> getRestaurants({
    required double lat,
    required double lng,
    bool isFlash = false,
    String? search,
    Map<String, dynamic>? filters,
    bool forSearchPage = false,
    int page = 1,
    bool append = false,
  }) async {
    // Reset correct pagination state when loading page 1
    if (page == 1) {
      if (isFlash) {
        _currentPageFlash = 1;
        _lastPageFlash = 1;
        _isPaginatingFlash = false;
      } else {
        _currentPageNormal = 1;
        _lastPageNormal = 1;
        _isPaginatingNormal = false;
      }
      _isLoading = true;
    }

    notifyListeners();

    final url = "${UrlPath.restaurantUrl.getNearbyFranchise}/$lat/$lng";
    final params = <String, String>{'page': page.toString()};
    if (isFlash) params['is_flash'] = '1';
    if (search?.trim().isNotEmpty ?? false) params['search'] = search!.trim();
    if (filters != null) filters.forEach((k, v) => params[k] = v.toString());

    debugPrint("🌍 Fetching restaurants => $url | Params: $params");

    try {
      final resp = await APIService.get(url, auth: true, params: params);

      if (resp.status) {
        final body = resp.fullBody as Map<String, dynamic>;
        final List<dynamic> data = body['data'] ?? [];
        final pagination = body['pagination'] ?? {};

        // Update correct pagination variables
        if (isFlash) {
          _currentPageFlash = pagination['current_page'] ?? 1;
          _lastPageFlash = pagination['last_page'] ?? 1;
        } else {
          _currentPageNormal = pagination['current_page'] ?? 1;
          _lastPageNormal = pagination['last_page'] ?? 1;
        }

        final List<Restaurant> list =
            data.map((e) => Restaurant.fromJson(e)).toList();

        // Replace or append depending on context
        if (forSearchPage) {
          _searchResults = append ? [..._searchResults, ...list] : list;
        } else if (isFlash) {
          _flashRestaurants =
              append ? [..._flashRestaurants, ...list] : list;
        } else {
          _restaurants = append ? [..._restaurants, ...list] : list;
        }

        error = null;
      } else {
        error = resp.message ?? "Failed to fetch restaurants.";
        if (forSearchPage) {
          _searchResults = [];
        } else if (isFlash) {
          _flashRestaurants = [];
        } else {
          _restaurants = [];
        }
      }
    } catch (e, st) {
      debugPrint("❌ Error fetching restaurants: $e");
      debugPrintStack(stackTrace: st);
      error = e.toString();
      if (forSearchPage) {
        _searchResults = [];
      } else if (isFlash) {
        _flashRestaurants = [];
      } else {
        _restaurants = [];
      }
    }

    _isLoading = false;
    _isPaginatingNormal = false;
    _isPaginatingFlash = false;
    notifyListeners();
  }

  // -------------------- PAGINATION --------------------
  Future<void> loadNextPageIfNeeded({
    required double lat,
    required double lng,
    bool isFlash = false,
    String? search,
    bool forSearchPage = false,
  }) async {
    if (isFlash) {
      if (_isPaginatingFlash || _currentPageFlash >= _lastPageFlash) {
        debugPrint("⚠️ Flash pagination halted: page=$_currentPageFlash / last=$_lastPageFlash");
        return;
      }
      _isPaginatingFlash = true;
      notifyListeners();

      await getRestaurants(
        lat: lat,
        lng: lng,
        isFlash: true,
        search: search,
        forSearchPage: forSearchPage,
        page: _currentPageFlash + 1,
        append: true,
      );

      _isPaginatingFlash = false;
    } else {
      if (_isPaginatingNormal || _currentPageNormal >= _lastPageNormal) {
        debugPrint("⚠️ Normal pagination halted: page=$_currentPageNormal / last=$_lastPageNormal");
        return;
      }
      _isPaginatingNormal = true;
      notifyListeners();

      await getRestaurants(
        lat: lat,
        lng: lng,
        isFlash: false,
        search: search,
        forSearchPage: forSearchPage,
        page: _currentPageNormal + 1,
        append: true,
      );

      _isPaginatingNormal = false;
    }

    notifyListeners();
  }

  // Future<void> getRestaurants({
  //   required double lat,
  //   required double lng,
  //   bool isFlash = false,
  //   String? search,
  //   Map<String, dynamic>? filters,
  //   bool forSearchPage = false,
  //   int page = 1, // 👈 pagination
  //   bool append = false, // 👈 merge new data
  // }) async {
  //   if (page == 1) {
  //     _currentPage = 1;
  //     _lastPage = 1;
  //     _isPaginating = false;
  //     _isLoading = true;
  //   }

  //   notifyListeners();

  //   final url = "${UrlPath.restaurantUrl.getNearbyFranchise}/$lat/$lng";
  //   final params = <String, String>{'page': page.toString()};
  //   if (isFlash) params['is_flash'] = '1';
  //   if (search?.trim().isNotEmpty ?? false) params['search'] = search!.trim();
  //   if (filters != null) filters.forEach((k, v) => params[k] = v.toString());

  //   debugPrint("🌍 Fetching restaurants => $url | Params: $params");

  //   try {
  //     final resp = await APIService.get(url, auth: true, params: params);

  //     if (resp.status) {
  //       final body = resp.fullBody as Map<String, dynamic>;
  //       final List<dynamic> data = body['data'] ?? [];
  //       final pagination = body['pagination'] ?? {};

  //       _currentPage = pagination['current_page'] ?? 1;
  //       _lastPage = pagination['last_page'] ?? 1;

  //       final List<Restaurant> list =
  //           data.map((e) => Restaurant.fromJson(e)).toList();

  //       // ✅ append or replace
  //       if (forSearchPage) {
  //         _searchResults = append ? [..._searchResults, ...list] : list;
  //       } else if (isFlash) {
  //         _flashRestaurants = append ? [..._flashRestaurants, ...list] : list;
  //       } else {
  //         _restaurants = append ? [..._restaurants, ...list] : list;
  //       }

  //       error = null;
  //     } else {
  //       error = resp.message ?? "Failed to fetch restaurants.";
  //       if (forSearchPage) {
  //         _searchResults = [];
  //       } else if (isFlash) {
  //         _flashRestaurants = [];
  //       } else {
  //         _restaurants = [];
  //       }
  //     }
  //   } catch (e, st) {
  //     debugPrint("❌ Error fetching restaurants: $e");
  //     debugPrintStack(stackTrace: st);
  //     error = e.toString();
  //     if (forSearchPage)
  //       _searchResults = [];
  //     else if (isFlash)
  //       _flashRestaurants = [];
  //     else
  //       _restaurants = [];
  //   }

  //   _isLoading = false;
  //   _isPaginating = false;
  //   notifyListeners();
  // }

  // // ---------------- LOAD NEXT PAGE ----------------
  // Future<void> loadNextPageIfNeeded({
  //   required double lat,
  //   required double lng,
  //   bool isFlash = false,
  //   String? search,
  //   bool forSearchPage = false, // ✅ added
  // }) async {
  //   if (_isPaginating || _currentPage >= _lastPage) {
  //     debugPrint("⚠️ Pagination halted: page=$_currentPage / last=$_lastPage");
  //     return;
  //   }

  //   _isPaginating = true;
  //   notifyListeners();

  //   await getRestaurants(
  //     lat: lat,
  //     lng: lng,
  //     isFlash: isFlash,
  //     search: search,
  //     forSearchPage: forSearchPage, // ✅ now correctly forwarded
  //     page: _currentPage + 1,
  //     append: true,
  //   );
  // }


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
        final data = resp.data is Map<String, dynamic> ? resp.data : {};
        final List<dynamic> bannerList = data['banner'] ?? [];
        final scrollData = data['scrolling_text'] ?? {};

        _banners =
            bannerList
                .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
                .toList();

        // ✅ Store scrolling text
        _scrollingText = scrollData['scrolling_text']?.toString() ?? '';

        _lastBannerFetch = now;
        error = null;
        debugPrint(
          "✅ Parsed ${_banners.length} banners & scrolling text: $_scrollingText",
        );
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
      debugPrint(
        "⚡ Loaded category $menuTypeId from cache (${_restaurants.length} items)",
      );
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

        debugPrint(
          "✅ Cached ${restaurants.length} restaurants for category $menuTypeId",
        );
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
