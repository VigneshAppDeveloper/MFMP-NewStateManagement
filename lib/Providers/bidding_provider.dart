import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/BidderModels/add_bidding_model.dart';
import '../models/BidderModels/get_bidding_model.dart';
import '../models/BidderModels/winner_model.dart';
import '../services/api_service.dart';
import '../services/ntp_service.dart';
import '../util/url_path.dart';
import '../widgets/dilogue/dilogue.dart';

class BiddingProvider extends ChangeNotifier {
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
  bool _biddingEndTriggered = false; // 🆕 Prevent duplicate dialogs

  final Map<String, bool> _menuLoading = {};
  Map<String, bool> get menuLoading => _menuLoading;

  VoidCallback? _onBiddingEnd;
  VoidCallback? get onBiddingEnd => _onBiddingEnd;
  set onBiddingEnd(VoidCallback? cb) => _onBiddingEnd = cb;

  Duration? _ntpOffset;
  // 🆕 Cache NTP offset for accuracy
  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    stopAll(); // cancel timers
    super.dispose();
  }

  // ---------- INITIALIZE ----------
  Future<void> initBidding({
    required String franchiseId,
    required String timerId,
    required List<BiddingModel> menus,
    required DateTime slotStart,
    required DateTime slotEnd,
  }) async {
    stopAll(); // 🆕 Prevent overlapping timers

    _biddings = menus;
    _slotStart = slotStart;
    _slotEnd = slotEnd;
    _biddingEnded = false;
    _biddingEndTriggered = false;

    // 🧭 Calculate accurate NTP offset once
    final now = DateTime.now();
    final serverTime = await NtpService().getCurrentIST();
    _ntpOffset = serverTime.difference(now);

    _remaining = slotEnd.difference(serverTime);
    notifyListeners();

    _startCountdown();
    _startPolling(franchiseId, timerId);
  }

  // ---------- ADD BIDDING ----------
  Future<bool> addBidding(BiddingRequestModel request) async {
    if (_isAdding) return false;
    _isAdding = true;
    notifyListeners();

    try {
      final resp = await APIService.post(
        UrlPath.biddingUrl.addBidding,
        data: request.toJson(),
        auth: true,
      );

      if (resp.status) {
        await getBidding(request.franchiseId, request.timerId, silent: true);
        return true;
      } else {
        AppDialogue.toast(resp.message ?? "Failed to place bid");
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

    try {
      final url = "${UrlPath.biddingUrl.getBidding}/$franchiseId/$timerId";
      final resp = await APIService.get(url, auth: true);

      if (resp.status && resp.fullBody['data'] != null) {
        final List data = resp.fullBody['data'];
        final newList = BiddingModel.listFromJson(data);

        // Mark menus as updating
        for (final bid in newList) {
          _menuLoading[bid.menuId] = true;
        }
        notifyListeners();

        // Filter only active ones
        final activeNewList =
            newList.where((newBid) {
              final base = double.tryParse(newBid.basePrice ?? "0") ?? 0;
              final high = double.tryParse(newBid.highestPrice) ?? 0;
              return base == 0 || high < base * 0.98;
            }).toList();

        // Smooth delta update
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

        // Remove expired menus
        _biddings.removeWhere((b) => !newList.any((n) => n.menuId == b.menuId));

        // End spinner
        Future.delayed(const Duration(milliseconds: 500), () {
          for (var id in newList.map((b) => b.menuId)) {
            _menuLoading[id] = false;
          }
          notifyListeners();
        });
      }
    } catch (e) {
      debugPrint("❌ getBidding error: $e");
    } finally {
      _isPolling = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------- COUNTDOWN ----------
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_slotEnd == null || _biddingEnded) return;

      // 🕓 Use cached NTP offset instead of calling every tick
      final now = DateTime.now().add(_ntpOffset ?? Duration.zero);
      final diff = _slotEnd!.difference(now);

      if (diff.isNegative) {
        _remaining = Duration.zero;
        _biddingEnded = true;
        stopAll();
        notifyListeners();

        if (!_biddingEndTriggered) {
          _biddingEndTriggered = true;
          _onBiddingEnd?.call();
        }
      } else {
        _remaining = diff;
        notifyListeners();
      }
    });
  }

  // ---------- POLLING ----------
  void _startPolling(String franchiseId, String timerId) {
    _pollTimer?.cancel();
    int interval = 5;
    int failures = 0;

    _pollTimer = Timer.periodic(Duration(seconds: interval), (timer) async {
      if (_biddingEnded) {
        timer.cancel();
        await _fetchWinnersAfterEnd(timerId);
        return;
      }

      try {
        await getBidding(franchiseId, timerId, silent: true);
        failures = 0;
      } catch (e) {
        failures++;
        if (failures >= 3) {
          interval = (interval * 2).clamp(5, 30);
          timer.cancel();
          _pollTimer = Timer.periodic(Duration(seconds: interval), (_) async {
            await getBidding(franchiseId, timerId, silent: true);
          });
          debugPrint("⚠️ Slowing polling to $interval sec");
        }
      }
    });
  }

  // ---------- WINNER FETCH ----------
  Future<void> _fetchWinnersAfterEnd(String timerId) async {
    if (_biddings.isEmpty) return;
    await Future.wait(
      _biddings.map((b) async {
        final winners = await getWinner(timerId, b.menuId);
        if (winners.isNotEmpty) {
          debugPrint("🏆 Winner for ${b.menuId}: ${winners.first.name}");
        }
      }),
    );
    notifyListeners();
  }

  Future<List<WinnerModel>> getWinner(String timerId, String menuId) async {
    final url = "${UrlPath.biddingUrl.getWinner}/$timerId/$menuId";
    try {
      final resp = await APIService.get(url, auth: true);
      if (resp.status && resp.fullBody['data']?['winners'] != null) {
        final List winnersJson = resp.fullBody['data']['winners'];
        return winnersJson.map((e) => WinnerModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("❌ getWinner error: $e");
    }
    return [];
  }

  // ---------- STOP ----------
  void stopAll() {
  _pollTimer?.cancel();
  _pollTimer = null;
  _countdownTimer?.cancel();
  _countdownTimer = null;
  debugPrint("🛑 Stopped all bidding timers");
}

  void clearData() {
    stopAll();
    _biddings = [];
    _winners = [];
    _biddingEnded = false;
    _biddingEndTriggered = false;
    _remaining = Duration.zero;
    notifyListeners();
  }
}
