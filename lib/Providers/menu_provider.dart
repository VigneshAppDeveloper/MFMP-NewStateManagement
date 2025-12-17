import 'dart:async';

import 'package:flutter/material.dart';

import '../models/BidderModels/timeslot_winner_list.dart';
import '../models/FoodModels/resturant_menu_model.dart';
import '../models/BidderModels/Bidder_count.dart';
import '../models/BidderModels/time_slot_model.dart';
import '../models/PickUptModels/pickup_point.dart';
import '../services/api_service.dart';
import '../services/ntp_service.dart';
import '../util/url_path.dart';

class MenuProvider extends ChangeNotifier {
  final Map<String, List<RestaurantMenuModel>> _cachedMenus =
      {}; // cache per franchiseId
  final Map<String, DateTime> _lastFetchedTime =
      {}; // track each restaurant's last fetch time

  List<RestaurantMenuModel> _menus = [];
  List<RestaurantMenuModel> get menus => _menus;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? error;

  // -------------------- TIME SLOT CACHING --------------------
  final Map<String, List<TimeSlotModel>> _cachedTimeSlots = {};
  final Map<String, DateTime> _lastFetchedTimeSlots = {};
  List<TimeSlotModel> _timeSlots = [];
  List<TimeSlotModel> get timeSlots => _timeSlots;
  bool _isTimeSlotLoading = false;
  bool get isTimeSlotLoading => _isTimeSlotLoading;

  Timer? _slotUpdateTimer;
  final NtpService _ntp = NtpService();

  // -------------------- BIDDER COUNT CACHING --------------------
  final Map<String, int> _bidderCounts = {}; // cache: timerId -> count
  final Map<String, DateTime> _lastFetchedBidder = {}; // cache timestamps
  Timer? _bidderUpdateTimer;

  /// Getter for UI
  Map<String, int> get bidderCounts => _bidderCounts;

  DateTime? _selectedPickupDate;
  //PickpointModel? _selectedPickupPoint;

  DateTime? get selectedPickupDate => _selectedPickupDate;
  //PickpointModel? get selectedPickupPoint => _selectedPickupPoint;

  bool _isActivePage = false;
  bool get isActivePage => _isActivePage;

  bool _isFlashMode = false;
  bool get isFlashMode => _isFlashMode;

  String? _currentFranchiseId;
  String? get currentFranchiseId => _currentFranchiseId;

  final Map<String, List<TimeSlotWinnerListModel>> _cachedWinnerList = {};
  final Map<String, DateTime> _lastWinnerFetch = {};
  List<TimeSlotWinnerListModel> _winnerList = [];
  List<TimeSlotWinnerListModel> get winnerList => _winnerList;

  int _winnerCount = 0;
  int get winnerCount => _winnerCount;

  int _totalBidderCount = 0;
  int get totalBidderCount => _totalBidderCount;

  bool _isWinnerLoading = false;
  bool get isWinnerLoading => _isWinnerLoading;

  void setActive(bool val) {
    _isActivePage = val;
    if (!val) stopAutoUpdaters();
  }

  // ✅ change this
  void setPickupDate(DateTime? date) {
    _selectedPickupDate = date;
    notifyListeners();
  }

  String _getCacheKey(String franchiseId, bool isFlash, String? date) {
    if (isFlash) return "${franchiseId}_flash";
    if (date == null) return "${franchiseId}_default";
    return "${franchiseId}_$date";
  }

  void clearPickupSelections() {
    _selectedPickupDate = null;
  }

  /// ✅ Fetch menu for a restaurant
  Future<void> getRestaurantMenu(
    String franchiseId, {
    bool forceRefresh = false,
    bool isFlash = false,
    String? pickupDate,
  }) async {
    _isFlashMode = isFlash;
    if (isFlash) stopAutoUpdaters();

    final cacheKey = _getCacheKey(franchiseId, isFlash, pickupDate);

    final now = DateTime.now();
    final lastFetch = _lastFetchedTime[cacheKey];

    // ✅ If switching restaurants, just load cached immediately if present
    if (_currentFranchiseId != franchiseId) {
  _currentFranchiseId = franchiseId;

  if (_cachedMenus.containsKey(cacheKey)) {
    _menus = List.from(_cachedMenus[cacheKey]!);
    notifyListeners();

    // Check expiry only
    if (lastFetch == null || now.difference(lastFetch).inMinutes >= 5 || forceRefresh) {
      unawaited(_backgroundMenuRefresh(franchiseId, isFlash: isFlash, pickupDate: pickupDate));
    }
    return;
  } else {
    _menus = [];
    notifyListeners();
  }
}


    // ✅ Use cache if still valid
    if (!forceRefresh &&
        _cachedMenus.containsKey(cacheKey) &&
        lastFetch != null &&
        now.difference(lastFetch).inMinutes < 5) {
      _menus = List<RestaurantMenuModel>.from(_cachedMenus[cacheKey]!);
      _currentFranchiseId = franchiseId;
      debugPrint("⚡ Served from cache: $franchiseId (${_menus.length} items)");
      notifyListeners();
      return;
    }

    // ✅ Otherwise fetch new data
    await _fetchAndCacheMenu(
      franchiseId,
      isFlash: isFlash,
      pickupDate: pickupDate,
    );
  }

  Future<void> _fetchAndCacheMenu(
    String franchiseId, {
    bool isFlash = false,
    String? pickupDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url = "${UrlPath.restaurantUrl.getFranchiseMenu}/$franchiseId";
    debugPrint("🚀 Fetching Menu API: $url (flash=$isFlash, date=$pickupDate)");

    try {
      final Map<String, String> params = {};
      if (isFlash) params['is_flash'] = '1';
      if (pickupDate != null) params['date'] = pickupDate;

      final resp = await APIService.get(
        url,
        auth: true,
        params: params.isEmpty ? null : params,
      );
      if (resp.status) {
        final List<dynamic> data = resp.data ?? [];
        _menus = data.map((e) => RestaurantMenuModel.fromJson(e)).toList();

        final cacheKey = _getCacheKey(franchiseId, isFlash, pickupDate);

        _cachedMenus[cacheKey] = List<RestaurantMenuModel>.from(_menus);
        _lastFetchedTime[cacheKey] = DateTime.now();

        error = null;
        debugPrint(
          "✅ Cached ${_menus.length} menus for $franchiseId (date=$pickupDate)",
        );
      } else {
        error = resp.message ?? "Failed to fetch menu.";
        _menus = [];
      }
    } catch (e) {
      error = e.toString();
      _menus = [];
      debugPrint("❌ Error fetching menu: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _backgroundMenuRefresh(
  String franchiseId, {
  bool isFlash = false,
  String? pickupDate,
}) async {
  try {
    debugPrint("🔄 Background refresh started for $franchiseId (date=$pickupDate)");
    await _fetchAndCacheMenu(
      franchiseId,
      isFlash: isFlash,
      pickupDate: pickupDate,
    );
  } catch (_) {
    debugPrint("⚠️ Background refresh failed for $franchiseId");
  }
}


  /// ✅ Clear specific restaurant menu cache
  void clearMenu(String key) {
  _cachedMenus.remove(key);
  _lastFetchedTime.remove(key);
}


  /// ✅ Clear all cached menus
  void clearAllMenus() {
    _cachedMenus.clear();
    _lastFetchedTime.clear();
    _menus = [];
    error = null;
    notifyListeners();
  }

  // ==================== TIME SLOT FETCH ====================
  Future<void> getTimeSlot(
    String franchiseId, {
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    final lastFetch = _lastFetchedTimeSlots[franchiseId];

    // ✅ Serve from cache if not expired
    if (!forceRefresh &&
        _cachedTimeSlots.containsKey(franchiseId) &&
        lastFetch != null &&
        now.difference(lastFetch).inMinutes < 5) {
      _timeSlots = _cachedTimeSlots[franchiseId]!;
      debugPrint("⚡ Loaded time slots from cache for franchise: $franchiseId");
      notifyListeners();
      _startSlotAutoUpdater(franchiseId); // ensure timer runs
      return;
    }

    _isTimeSlotLoading = true;
    notifyListeners();

    final url = "${UrlPath.biddingUrl.getTimeSlots}/$franchiseId";
    debugPrint("⏱️ Fetching TimeSlot API: $url");

    try {
      final resp = await APIService.get(url, auth: true);
      debugPrint("📡 TimeSlot RESPONSE STATUS: ${resp.status}");

      if (resp.status) {
        // ✅ Handle both `{data: [...]}` and `{results: [...]}`
        List<dynamic> results = [];

        if (resp.data is Map<String, dynamic>) {
          results = resp.data['results'] ?? resp.data['data'] ?? [];
        } else if (resp.data is List) {
          results = resp.data;
        }

        _timeSlots = results.map((e) => TimeSlotModel.fromJson(e)).toList();

        _cachedTimeSlots[franchiseId] = _timeSlots;
        _lastFetchedTimeSlots[franchiseId] = now;

        // ✅ Sort slots chronologically
        _timeSlots.sort((a, b) => a.startTime.compareTo(b.startTime));

        // ✅ Start background updates
        _startSlotAutoUpdater(franchiseId);

        debugPrint("🟢 Cached ${_timeSlots.length} slots for $franchiseId");
      } else {
        _timeSlots = [];
      }
    } catch (e) {
      debugPrint("❌ Error fetching time slots: $e");
      _timeSlots = [];
    }

    _isTimeSlotLoading = false;
    notifyListeners();
  }

  /// ✅ Fetch bidder count for a specific timer
  Future<int> getBidderCount(
    String timerId, {
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    final lastFetch = _lastFetchedBidder[timerId];

    // ✅ Return from cache if fresh (<30 sec)
    if (!forceRefresh &&
        _bidderCounts.containsKey(timerId) &&
        lastFetch != null &&
        now.difference(lastFetch).inSeconds < 30) {
      debugPrint("⚡ Using cached bidder count for $timerId");
      return _bidderCounts[timerId]!;
    }

    final url = "${UrlPath.biddingUrl.getBidderCount}/$timerId";
    debugPrint("👥 Fetching Bidder Count API: $url");

    try {
      final resp = await APIService.get(url, auth: true);
      if (resp.status && resp.data != null) {
        int count = 0;

        if (resp.data is Map<String, dynamic>) {
          // full map returned
          final model = BidderCountModel.fromJson(resp.data);
          count = model.bidderCount;
        } else if (resp.data is int) {
          // backend or APIService returned raw integer
          count = resp.data;
        }

        _bidderCounts[timerId] = count;
        _lastFetchedBidder[timerId] = now;
        notifyListeners();
        debugPrint("✅ Bidder count ($timerId): $count");
        return count;
      }
    } catch (e) {
      debugPrint("❌ Error fetching bidder count for $timerId: $e");
    }

    return _bidderCounts[timerId] ?? 0;
  }

  // ==================== AUTO STATE UPDATER ====================
  void _startSlotAutoUpdater(String franchiseId) {
    // Cancel all previous timers before starting new
    _slotUpdateTimer?.cancel();
    _bidderUpdateTimer?.cancel();

    // Update slot states every 30s
    _slotUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _updateSlotStates();

      // After updating states, only then update bidder counts for active slots
      if (_timeSlots.isNotEmpty) {
        final activeSlots = _timeSlots.where((slot) => slot.isActive).toList();
        if (activeSlots.isNotEmpty) {
          debugPrint(
            "🔁 Updating bidder counts for ${activeSlots.length} active slots",
          );
          for (final slot in activeSlots) {
            await getBidderCount(slot.timerId, forceRefresh: true);
          }
        }
      }
    });

    // Run both once immediately
    _updateSlotStates();
    _fetchBidderCountsForActiveSlots();
  }

  Future<void> _fetchBidderCountsForActiveSlots() async {
    if (_timeSlots.isEmpty) return;
    final activeSlots = _timeSlots.where((slot) => slot.isActive).toList();
    if (activeSlots.isEmpty) return;

    debugPrint(
      "⚡ Initial bidder count fetch for ${activeSlots.length} active slots",
    );
    for (final slot in activeSlots) {
      await getBidderCount(slot.timerId, forceRefresh: true);
    }
  }

  Future<void> _updateSlotStates() async {
    if (_timeSlots.isEmpty) return;

    final istNow = await _ntp.getCurrentIST();
    bool changed = false;

    for (var slot in _timeSlots) {
      final start = slot.startTime;
      final end = slot.endTime;

      final wasActive = slot.isActive;
      final wasUpcoming = slot.isUpcoming;
      final wasCompleted = slot.isCompleted;

      slot.isActive = istNow.isAfter(start) && istNow.isBefore(end);
      slot.isUpcoming = istNow.isBefore(start);
      slot.isCompleted = istNow.isAfter(end);

      if (slot.isActive != wasActive ||
          slot.isUpcoming != wasUpcoming ||
          slot.isCompleted != wasCompleted) {
        changed = true;
      }
    }

    if (changed) {
      debugPrint("🔄 Slot states updated at $istNow");
      notifyListeners();
    }
  }

  // ✅ Manual refresh
  Future<void> refreshTimeSlot(String franchiseId) async {
    await getTimeSlot(franchiseId, forceRefresh: true);
  }

  // ✅ Clear cache for one restaurant
  void clearTimeSlot(String franchiseId) {
    _cachedTimeSlots.remove(franchiseId);
    _lastFetchedTimeSlots.remove(franchiseId);
    if (_timeSlots.isNotEmpty && _timeSlots.first.franchiseId == franchiseId) {
      _timeSlots = [];
    }
    notifyListeners();
  }

  // ✅ Clear all cached data
  void clearAll() {
    _cachedMenus.clear();
    _cachedTimeSlots.clear();
    _lastFetchedTime.clear();
    _lastFetchedTimeSlots.clear();
    _menus = [];
    _timeSlots = [];
    error = null;
    _slotUpdateTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _slotUpdateTimer?.cancel();
    _bidderUpdateTimer?.cancel();
    super.dispose();
  }

  void stopAutoUpdaters() {
    _slotUpdateTimer?.cancel();
    _bidderUpdateTimer?.cancel();
    _slotUpdateTimer = null;
    _bidderUpdateTimer = null;
    debugPrint("🛑 All auto-updaters stopped (user left page or app)");
  }

  void resumeAutoUpdaters(String franchiseId) {
    if (_slotUpdateTimer == null || !_slotUpdateTimer!.isActive) {
      _startSlotAutoUpdater(franchiseId);
      debugPrint("▶️ Auto-updaters resumed for $franchiseId");
    }
  }

  Future<void> getTimeSlotWinnerList({
    required String franchiseId,
    required String timerId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = "$franchiseId-$timerId";
    final now = DateTime.now();
    final lastFetch = _lastWinnerFetch[cacheKey];

    if (!forceRefresh &&
        _cachedWinnerList.containsKey(cacheKey) &&
        lastFetch != null &&
        now.difference(lastFetch).inMinutes < 5) {
      _winnerList = _cachedWinnerList[cacheKey]!;
      debugPrint("⚡ Served winner list from cache for $cacheKey");
      notifyListeners();
      return;
    }

    _isWinnerLoading = true;
    notifyListeners();

    final url =
        "${UrlPath.biddingUrl.getTimeSlotWinnerList}/$franchiseId/$timerId";
    debugPrint("🏆 Fetching Winner List API: $url");

    try {
      final resp = await APIService.get(url, auth: true);
      debugPrint("📡 Winner RESPONSE: ${resp.fullBody}");

      if (resp.status) {
        final parsed = TimeSlotWinnerResponse.fromJson(resp.data ?? {});

        _winnerList = parsed.winners;
        _winnerCount = parsed.winnerCount;
        _totalBidderCount = parsed.totalBidderCount;

        _cachedWinnerList[cacheKey] = List<TimeSlotWinnerListModel>.from(
          _winnerList,
        );
        _lastWinnerFetch[cacheKey] = now;

        error = null;
        debugPrint(
          "✅ Cached ${_winnerList.length} winners (count=${_winnerCount}, bidders=${_totalBidderCount})",
        );
      } else {
        error = resp.message ?? "Failed to fetch winner list.";
        _winnerList = [];
      }
    } catch (e) {
      error = e.toString();
      _winnerList = [];
      debugPrint("❌ Error fetching winners: $e");
    }

    _isWinnerLoading = false;
    notifyListeners();
  }
}
