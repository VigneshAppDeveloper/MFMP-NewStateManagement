import 'package:flutter/material.dart';
import '../models/rating_model.dart';
import '../services/api_service.dart';
import '../util/url_path.dart';

class RatingsProvider extends ChangeNotifier {
  // -------------------- STATES --------------------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? errorMessage;

  // -------------------- DATA --------------------
  List<RatingModel> _ratings = [];
  List<RatingModel> get ratings => _ratings;

  double _averageRating = 0.0;
  double get averageRating => _averageRating;

  // ✅ Local ratings for each menu (before submit)
  final Map<String, double> _menuRatings = {};
  Map<String, double> get menuRatings => _menuRatings;

  DateTime? _lastFetchTime;
  static const Duration cacheDuration = Duration(minutes: 5);


  bool canSubmit(String feedback) {
  final hasRating = _menuRatings.values.any((r) => r > 0);
  final hasFeedback = feedback.trim().isNotEmpty;
  return hasRating || hasFeedback;
}


  // ================================================================
  // ✅ Fetch Franchise Ratings (GET)
  // ================================================================
 Future<void> getFeedback({
  required String franchiseId,
  bool forceRefresh = false,
}) async {
  final now = DateTime.now();

  if (!forceRefresh &&
      _lastFetchTime != null &&
      now.difference(_lastFetchTime!) < cacheDuration &&
      _ratings.isNotEmpty) {
    debugPrint("⚡ Loaded ratings from cache");
    notifyListeners();
    return;
  }

  _isLoading = true;
  errorMessage = null;
  notifyListeners();

  final url = "${UrlPath.ratingUrl.getFranchiseRating}/$franchiseId";
  debugPrint("📡 Fetching Ratings: $url");

  try {
    // ✅ Use GET (API is read-only)
    final resp = await APIService.get(url, auth: true);

    debugPrint("📡 RESPONSE STATUS: ${resp.status}");
    debugPrint("📡 RAW RESPONSE DATA: ${resp.data}");

    // ✅ Correct extraction: resp.data itself holds the useful map
    final data = resp.data;

    if (data != null && data['franchise_rating'] != null) {
      final ratingList = data['franchise_rating'] as List;
      _ratings = ratingList.map((e) => RatingModel.fromJson(e)).toList();
      _averageRating =
          double.tryParse(data['average_rating']?.toString() ?? '0') ?? 0;
      _lastFetchTime = now;
      errorMessage = null;
    } else {
      errorMessage = "Invalid data format";
      _ratings = [];
    }
  } catch (e, st) {
    errorMessage = e.toString();
    _ratings = [];
    debugPrint("❌ Ratings Fetch Error: $e\n$st");
  }

  _isLoading = false;
  notifyListeners();
}


  // ================================================================
  // ✅ Update Local Rating per Menu (used in RatingBar)
  // ================================================================
  void updateMenuRating(String menuId, double rating) {
    _menuRatings[menuId] = rating;
    notifyListeners();
  }

  // ================================================================
  // ✅ Submit Ratings for all Menus + Feedback
  // ================================================================
  Future<bool> submitRatings({
    required BuildContext context,
    required List<String> orderIds,
    required List<String> menuCategoryIds,
    required String franchiseId,
    required String feedback,
  }) async {
    try {
      // Convert map values into list aligned with menuCategoryIds
      final starRatings =
          menuCategoryIds.map((id) => _menuRatings[id] ?? 0.0).toList();

      // Validation: ensure all rated
      // if (starRatings.any((r) => r == 0.0)) {
      // Dialogs.snackbar("Please rate all menu items", context);
      //   return false;
      // }

      final url = UrlPath.ratingUrl.addFranchiseRating;
      debugPrint("📡 Submitting Ratings: $url");

      final payload = {
        "franchise_id": franchiseId,
        "order_ids": orderIds,
        "menu_ids": menuCategoryIds,
        "starRatings": starRatings,
        "user_feedback": feedback,
      };

      final resp = await APIService.post(url, data: payload, auth: true);

      if (resp.status) {
        await getFeedback(franchiseId: franchiseId, forceRefresh: true);
        _menuRatings.clear();
        return true;
      } else {
        errorMessage = resp.message ?? "Failed to submit ratings.";
        return false;
      }
    } catch (e, st) {
      errorMessage = e.toString();
      debugPrint("❌ Submit Ratings Error: $e\n$st");
      return false;
    } finally {
      notifyListeners();
    }
  }

  // ================================================================
  // ✅ Clear Cache
  // ================================================================
  void clearCache() {
    _ratings.clear();
    _menuRatings.clear();
    _averageRating = 0.0;
    _lastFetchTime = null;
    notifyListeners();
  }
}
