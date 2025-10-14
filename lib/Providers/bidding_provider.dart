import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/BidderModels/add_bidding_model.dart';
import '../models/BidderModels/get_bidding_model.dart';
import '../models/BidderModels/winner_model.dart';
import '../services/api_service.dart';
import '../services/ntp_service.dart';
import '../util/url_path.dart';

class BiddingProvider extends ChangeNotifier {
  // ---------- STATE ----------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAdding = false;
  bool get isAdding => _isAdding;

  bool _biddingEnded = false;
  bool get biddingEnded => _biddingEnded;

  List<BiddingModel> _biddings = [];
  List<BiddingModel> get biddings => _biddings;

  List<WinnerModel> _winners = [];
  List<WinnerModel> get winners => _winners;

  Duration _remaining = Duration.zero;
  Duration get remaining => _remaining;

  DateTime? _slotStart;
  DateTime? _slotEnd;

  Timer? _pollTimer;
  Timer? _countdownTimer;

  bool _isPolling = false;

  final Map<String, bool> _menuLoading = {};
  Map<String, bool> get menuLoading => _menuLoading;

// ---------- CALLBACK WHEN BIDDING ENDS ----------
VoidCallback? _onBiddingEnd; // private field
VoidCallback? get onBiddingEnd => _onBiddingEnd;
set onBiddingEnd(VoidCallback? callback) => _onBiddingEnd = callback;



  // ---------- INITIALIZE ----------
  Future<void> initBidding({
    required String franchiseId,
    required String timerId,
    required List<BiddingModel> menus,
    required DateTime slotStart,
    required DateTime slotEnd,
  }) async {
    _biddings = menus;
    _slotStart = slotStart;
    _slotEnd = slotEnd;
    _biddingEnded = false;
    _remaining = slotEnd.difference(DateTime.now());
    notifyListeners();

    _startCountdown();
    _startPolling(franchiseId, timerId);
  }

  // ---------- ADD BIDDING ----------
  Future<bool> addBidding(BiddingRequestModel request) async {
    if (_isAdding) return false;
    _isAdding = true;
    notifyListeners();
  debugPrint("Adding bidding: ${request.toJson()}");

    try {
      final resp = await APIService.post(
        UrlPath.biddingUrl.addBidding,
        data: request.toJson(),
        auth: true,
      );

      if (resp.status) {
        debugPrint("✅ Bidding updated successfully");
        // refresh bids immediately
        await getBidding(request.franchiseId, request.timerId, silent: true);
        return true;
      } else {
        debugPrint("❌ Failed to add bidding: ${resp.message}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Exception in addBidding: $e");
      return false;
    } finally {
      _isAdding = false;
      notifyListeners();
    }
  }

  // ---------- GET BIDDING ----------
  Future<void> getBidding(
    String franchiseId,
    String timerId, {
    bool silent = false,
  }) async {
    if (_isPolling) return;
    _isPolling = true;
    if (!silent) _isLoading = true;
    notifyListeners();

    final url = "${UrlPath.biddingUrl.getBidding}/$franchiseId/$timerId";
    try {
      final resp = await APIService.get(url, auth: true);

      if (resp.status && resp.fullBody['data'] != null) {
        final List data = resp.fullBody['data'];
        final newList = BiddingModel.listFromJson(data);

        // 🔹 Mark each menu as live-updating (for spinner)
        for (final bid in newList) {
          _menuLoading[bid.menuId] = true;
        }
        notifyListeners();

        // ✅ Skip menus already at price cap (basePrice * 0.98)
        final activeNewList =
            newList.where((newBid) {
              final basePrice = double.tryParse(newBid.basePrice ?? "0") ?? 0;
              final highest = double.tryParse(newBid.highestPrice) ?? 0;
              return basePrice == 0 || highest < basePrice * 0.98;
            }).toList();

        // ✅ Delta update (no flicker)
        for (final newBid in activeNewList) {
          final index = _biddings.indexWhere((b) => b.menuId == newBid.menuId);
          if (index != -1) {
            final oldBid = _biddings[index];
            if (oldBid.highestPrice != newBid.highestPrice ||
                oldBid.name != newBid.name) {
              _biddings[index] = newBid;
            }
          } else {
            _biddings.add(newBid);
          }
        }

        // 🔹 Remove old ones not in backend
        _biddings.removeWhere((b) => !newList.any((n) => n.menuId == b.menuId));

        if (kDebugMode) {
          debugPrint("✅ Data: ${resp.fullBody['data']}");
          debugPrint("🔄 Live bidding data updated (${_biddings.length})");
        }

        // 🔹 End spinner smoothly
        Future.delayed(const Duration(milliseconds: 800), () {
          for (var id in newList.map((b) => b.menuId)) {
            _menuLoading[id] = false;
          }
          notifyListeners();
        });
      } else {
        _biddings = [];
      }
    } catch (e) {
      debugPrint("❌ Exception in getBidding: $e");
    } finally {
      _isPolling = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------- COUNTDOWN TIMER ----------
 void _startCountdown() {
  _countdownTimer?.cancel();
  _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
    if (_slotEnd == null) return;

    final now = await NtpService().getCurrentIST();
    final diff = _slotEnd!.difference(now);

   if (diff.isNegative) {
  _remaining = Duration.zero;
  _biddingEnded = true;
  stopAll();
  notifyListeners();

  // 🔹 Trigger callback once bidding fully ends
  _onBiddingEnd?.call();
}
 else {
      _remaining = diff;
      notifyListeners();
    }
  });
}


  // ---------- POLLING LOOP ----------
  void _startPolling(String franchiseId, String timerId) {
    _pollTimer?.cancel();

    // 🔹 Adaptive interval based on active bids
    int interval =
        _biddings.any((b) {
              final base = double.tryParse(b.basePrice ?? "0") ?? 0;
              final current = double.tryParse(b.highestPrice) ?? 0;
              return base == 0 || current < base * 0.98; // active bids exist
            })
            ? 5
            : 10;

    int failureCount = 0;

    _pollTimer = Timer.periodic(Duration(seconds: interval), (timer) async {
      if (_biddingEnded) {
        timer.cancel();
        await _fetchWinnersAfterEnd(timerId);
        return;
      }

      try {
        await getBidding(franchiseId, timerId, silent: true);
        failureCount = 0;
      } catch (e) {
        failureCount++;
        if (failureCount >= 3) {
          // ⚠️ Slow down polling to reduce server load
          interval = (interval * 2).clamp(5, 30);
          timer.cancel();
          _pollTimer = Timer.periodic(Duration(seconds: interval), (t) async {
            await getBidding(franchiseId, timerId, silent: true);
          });
          debugPrint("⚠️ Network unstable — slowing poll to every $interval s");
        }
      }
    });

    debugPrint("🚀 Polling started every $interval seconds");
  }

  // ---------- WINNER FETCH ----------
  Future<void> _fetchWinnersAfterEnd(String timerId) async {
    debugPrint("🏁 Bidding ended — fetching winners...");
    if (_biddings.isEmpty) return;

    // For each menu, request winner
    for (final bid in _biddings) {
      final menuId = bid.menuId;
      final winners = await getWinner(timerId, menuId);
      if (winners.isNotEmpty) {
        debugPrint("🏆 Winners for menu $menuId: ${winners.first.name}");
      }
    }
    notifyListeners();
  }

  Future<List<WinnerModel>> getWinner(String timerId, String menuId) async {
    final url = "${UrlPath.biddingUrl.getWinner}/$timerId/$menuId";
    try {
      final resp = await APIService.get(url, auth: true);
      if (resp.status && resp.fullBody['data']?['winners'] != null) {
        final List winnersJson = resp.fullBody['data']['winners'];
        return winnersJson.map((e) => WinnerModel.fromJson(e)).toList();
      } else {
         return [];
      }
    
    } catch (e) {
      debugPrint("❌ Exception in getWinner: $e");
      return [];
    }
  }

  // ---------- STOP ALL ----------
  void stopAll() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    debugPrint("🛑 Stopped bidding timers");
  }

  // ---------- CLEAR ----------
  void clearData() {
    stopAll();
    _biddings = [];
    _winners = [];
    _biddingEnded = false;
    _remaining = Duration.zero;
    notifyListeners();
  }
}
