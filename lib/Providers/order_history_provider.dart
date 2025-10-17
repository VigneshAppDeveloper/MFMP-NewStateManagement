import 'package:flutter/material.dart';

import '../models/OrderModels/order_model.dart';
import '../services/api_service.dart';
import '../util/url_path.dart';

class OrderHistoryProvider extends ChangeNotifier {
  // -------------------- STATES --------------------
  bool _isFixedLoading = false;
  bool get isFixedLoading => _isFixedLoading;

  bool _isBiddingLoading = false;
  bool get isBiddingLoading => _isBiddingLoading;

  String? errorMessage;

  // -------------------- DATA --------------------
  List<OrderDetailModel> _fixedOrders = [];
  List<OrderDetailModel> get fixedOrders => _fixedOrders;

  List<OrderDetailModel> _biddingOrders = [];
  List<OrderDetailModel> get biddingOrders => _biddingOrders;

  DateTime? _lastFixedFetch;
  DateTime? _lastBiddingFetch;

  // ✅ Common cache duration
  static const Duration cacheDuration = Duration(minutes: 10);

  // ================================================================
  // ✅ Fetch Fixed Orders
  // ================================================================
  Future<void> getFixedOrders({bool forceRefresh = false}) async {
    final now = DateTime.now();

    // ✅ Serve from cache if still valid
    if (!forceRefresh &&
        _lastFixedFetch != null &&
        now.difference(_lastFixedFetch!) < cacheDuration &&
        _fixedOrders.isNotEmpty) {
      debugPrint("⚡ Loaded Fixed Orders from cache");
      notifyListeners();
      return;
    }

    _isFixedLoading = true;
    notifyListeners();

    final url = UrlPath.orderUrl.getFixedOrderDetails;
    debugPrint("📡 Fetching Fixed Orders API: $url");

    try {
      final resp = await APIService.get(url, auth: true);

      if (resp.status && resp.data != null) {
        final data =
            resp.data is Map<String, dynamic>
                ? resp.data['data'] ?? []
                : resp.data;

        _fixedOrders = List<OrderDetailModel>.from(
          (data as List).map((e) => OrderDetailModel.fromJson(e)),
        );

        _fixedOrders.sort(
          (a, b) => b.createdDateTime.compareTo(a.createdDateTime),
        );

        _lastFixedFetch = now;
        errorMessage = null;
      } else {
        errorMessage = resp.message ?? "Failed to fetch fixed orders.";
        _fixedOrders = [];
      }
    } catch (e, st) {
      errorMessage = e.toString();
      _fixedOrders = [];
      debugPrint("❌ Fixed Orders Error: $e\n$st");
    }

    _isFixedLoading = false;
    notifyListeners();
  }

  // ================================================================
  // ✅ Fetch Bidding Orders
  // ================================================================
  Future<void> getBiddingOrders({bool forceRefresh = false}) async {
    final now = DateTime.now();

    // ✅ Serve from cache if still valid
    if (!forceRefresh &&
        _lastBiddingFetch != null &&
        now.difference(_lastBiddingFetch!) < cacheDuration &&
        _biddingOrders.isNotEmpty) {
      debugPrint("⚡ Loaded Bidding Orders from cache");
      notifyListeners();
      return;
    }

    _isBiddingLoading = true;
    notifyListeners();

    final url = UrlPath.orderUrl.getBiddingOrderDetails;
    debugPrint("📡 Fetching Bidding Orders API: $url");

    try {
      final resp = await APIService.get(url, auth: true);

      if (resp.status && resp.data != null) {
        final data =
            resp.data is Map<String, dynamic>
                ? resp.data['data'] ?? []
                : resp.data;

        _biddingOrders = List<OrderDetailModel>.from(
          (data as List).map((e) => OrderDetailModel.fromJson(e)),
        );
        _biddingOrders.sort(
          (a, b) => b.createdDateTime.compareTo(a.createdDateTime),
        );

        _lastBiddingFetch = now;
        errorMessage = null;
      } else {
        errorMessage = resp.message ?? "Failed to fetch bidding orders.";
        _biddingOrders = [];
      }
    } catch (e, st) {
      errorMessage = e.toString();
      _biddingOrders = [];
      debugPrint("❌ Bidding Orders Error: $e\n$st");
    }

    _isBiddingLoading = false;
    notifyListeners();
  }

  // ================================================================
  // ✅ Manual refresh methods
  // ================================================================
  Future<void> refreshFixedOrders() async =>
      await getFixedOrders(forceRefresh: true);

  Future<void> refreshBiddingOrders() async =>
      await getBiddingOrders(forceRefresh: true);

  // ================================================================
  // ✅ Clear Cache
  // ================================================================
  void clearCache() {
    _fixedOrders.clear();
    _biddingOrders.clear();
    _lastFixedFetch = null;
    _lastBiddingFetch = null;
    notifyListeners();
  }
}
