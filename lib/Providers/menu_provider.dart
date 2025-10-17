import 'dart:async';

import 'package:flutter/material.dart';

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
  PickpointModel? _selectedPickupPoint;

  DateTime? get selectedPickupDate => _selectedPickupDate;
  PickpointModel? get selectedPickupPoint => _selectedPickupPoint;

  bool _isActivePage = false;
  bool get isActivePage => _isActivePage;

  bool _isFlashMode = false;
  bool get isFlashMode => _isFlashMode;

  String? _currentFranchiseId;
String? get currentFranchiseId => _currentFranchiseId;


  void setActive(bool val) {
    _isActivePage = val;
    if (!val) stopAutoUpdaters();
  }

  void setPickupDate(DateTime date) {
    _selectedPickupDate = date;
    notifyListeners();
  }

  void setPickupPoint(PickpointModel point) {
    _selectedPickupPoint = point;
    debugPrint("📍 Pickup point set: ${point.pickupLocation}");
    debugPrint("📅 Current selected date: $_selectedPickupDate");
    notifyListeners();
  }

  void clearPickupSelections() {
    _selectedPickupDate = null;
    _selectedPickupPoint = null;
    // notifyListeners();
  }

  /// ✅ Fetch menu for a restaurant
Future<void> getRestaurantMenu(
  String franchiseId, {
  bool forceRefresh = false,
  bool isFlash = false,
}) async {
  _isFlashMode = isFlash;
  if (isFlash) stopAutoUpdaters();

  final cacheKey = isFlash ? "${franchiseId}_flash" : franchiseId;
  final now = DateTime.now();
  final lastFetch = _lastFetchedTime[cacheKey];

  // ✅ If switching restaurants, just load cached immediately if present
  if (_currentFranchiseId != franchiseId) {
    _currentFranchiseId = franchiseId;
    if (_cachedMenus.containsKey(cacheKey)) {
      debugPrint("📦 Switched restaurant → using cached menu for $franchiseId");
      _menus = List<RestaurantMenuModel>.from(_cachedMenus[cacheKey]!);
      notifyListeners();
      // If cache older than 10 min, silently refresh in background
      if (lastFetch == null ||
          now.difference(lastFetch).inMinutes >= 10 ||
          forceRefresh) {
        unawaited(_backgroundMenuRefresh(franchiseId, isFlash: isFlash));
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
      now.difference(lastFetch).inMinutes < 10) {
    _menus = List<RestaurantMenuModel>.from(_cachedMenus[cacheKey]!);
    _currentFranchiseId = franchiseId;
    debugPrint("⚡ Served from cache: $franchiseId (${_menus.length} items)");
    notifyListeners();
    return;
  }

  // ✅ Otherwise fetch new data
  await _fetchAndCacheMenu(franchiseId, isFlash: isFlash);
}


Future<void> _fetchAndCacheMenu(String franchiseId, {bool isFlash = false}) async {
  _isLoading = true;
  notifyListeners();

  final url = "${UrlPath.restaurantUrl.getFranchiseMenu}/$franchiseId";
  debugPrint("🚀 Fetching Menu API: $url (flash=$isFlash)");

  try {
    final resp = await APIService.get(
      url,
      auth: true,
      params: isFlash ? {'is_flash': '1'} : null,
    );

    if (resp.status) {
      final List<dynamic> data = resp.data ?? [];
      _menus = data.map((e) => RestaurantMenuModel.fromJson(e)).toList();

      _cachedMenus[isFlash ? "${franchiseId}_flash" : franchiseId] =
          List<RestaurantMenuModel>.from(_menus);
      _lastFetchedTime[isFlash ? "${franchiseId}_flash" : franchiseId] =
          DateTime.now();

      error = null;
      debugPrint("✅ Cached ${_menus.length} menus for $franchiseId");
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

Future<void> _backgroundMenuRefresh(String franchiseId, {bool isFlash = false}) async {
  try {
    debugPrint("🔄 Background refresh started for $franchiseId");
    await _fetchAndCacheMenu(franchiseId, isFlash: isFlash);
  } catch (_) {
    debugPrint("⚠️ Background refresh failed for $franchiseId");
  }
}


  /// ✅ Clear specific restaurant menu cache
  void clearMenu(String franchiseId) {
    _cachedMenus.remove(franchiseId);
    _lastFetchedTime.remove(franchiseId);
    if (_menus.isNotEmpty && _menus.first.franchiseId == franchiseId) {
      _menus = [];
    }
      debugPrint("🧹 Cleared menu cache for $franchiseId");

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
        now.difference(lastFetch).inMinutes < 10) {
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
}
