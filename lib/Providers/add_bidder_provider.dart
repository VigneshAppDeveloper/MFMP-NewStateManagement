import 'package:flutter/material.dart';

import '../models/BidderModels/bidder_response.dart';
import '../services/api_service.dart';
import '../util/url_path.dart';


class BidderProvider extends ChangeNotifier {
  bool _isAdding = false;
  bool get isAdding => _isAdding;

  // ✅ Cache joined timerIds (avoid re-calling API)
  final Set<String> _joinedTimerIds = {};
  Set<String> get joinedTimerIds => _joinedTimerIds;

  // 🧩 Add bidder to a timer slot
  Future<BidderResponseModel> addBidder({
    required String userId,
    required String name,
    required String timerId,
  }) async {
    // Prevent re-joining the same slot
    if (_joinedTimerIds.contains(timerId)) {
      debugPrint("⚠️ Already joined this timer_id: $timerId");
      return BidderResponseModel(
        success: true,
        message: "Already joined this slot",
      );
    }

    if (_isAdding) {
      debugPrint("⚠️ Bidder request already in progress — ignoring duplicate tap.");
      return BidderResponseModel(success: false, message: "Please wait...");
    }

    _isAdding = true;
    notifyListeners();

    final url = UrlPath.biddingUrl.createBidder;
    debugPrint("🚀 Adding bidder to timer: $timerId");

    try {
      final resp = await APIService.post(
        url,
        auth: true,
        data: {
          "user_id": userId,
          "name": name,
          "timer_id": timerId,
        },
      );

      if (resp.status && resp.fullBody != null) {
        final model = BidderResponseModel.fromJson(resp.fullBody);

        if (model.success) _joinedTimerIds.add(timerId); // mark joined

        debugPrint("✅ Bidder added successfully: ${model.message}");
        return model;
      } else {
        // Handle backend “already exists” case
        final msg = resp.fullBody?['message'] ?? resp.message ?? "";
        if (msg.contains("already exists")) {
          _joinedTimerIds.add(timerId);
          return BidderResponseModel(
            success: true,
            message: "Already joined this slot",
          );
        }
        return BidderResponseModel(success: false, message: msg);
      }
    } catch (e) {
      debugPrint("❌ Exception while adding bidder: $e");
      return BidderResponseModel(success: false, message: e.toString());
    } finally {
      _isAdding = false;
      notifyListeners();
    }
  }

  // ✅ Reset when user logs out or app restarts
  void clearJoinedTimers() {
    _joinedTimerIds.clear();
    notifyListeners();
  }
}