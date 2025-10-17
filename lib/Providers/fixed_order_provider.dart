import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/url_path.dart';

import '../models/OrderModels/order_bidding_reponse.dart';
import '../models/OrderModels/paymnet_reponse.dart';
import '../models/PickUptModels/pickup_time_model.dart';
import '../services/api_service.dart';
class FixedOrderProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  OrderBiddingResponse? _lastResponse;
  OrderBiddingResponse? get lastResponse => _lastResponse;

  PaymentStatusResponse? _paymentStatus;
  PaymentStatusResponse? get paymentStatus => _paymentStatus;

  String? errorMessage;

  List<PickupTimeModel> _pickupTimes = [];
  List<PickupTimeModel> get pickupTimes => _pickupTimes;

  PickupTimeModel? _selectedPickupTime;
  PickupTimeModel? get selectedPickupTime => _selectedPickupTime;
  set selectedPickupTime(PickupTimeModel? val) {
    _selectedPickupTime = val;
    notifyListeners();
  }

  bool _isPickupTimeLoading = false;
  bool get isPickupTimeLoading => _isPickupTimeLoading;

  /// ✅ Place Fixed Order (same as bidding but no timer_id)
 Future<Map<String, dynamic>> placeFixedOrder({
  required String franchiseId,
  required String userId,
  required List<String> menuIds,
  required List<String> menuNames,
  required List<String> menuQuantities,
  required List<String> totalMenuPrices,
  required String name,
  required String pickupPoint,
  required String pickupTime,
  required String mobile,
  required String transactionAmount,
  required String merchantTransactionId,
  required String wallet,
  required String gst,
  required String pickupDate,
  required int contactCustomer,
}) async {
  _isLoading = true;
  notifyListeners();

  final Map<String, dynamic> data = {
    "franchise_id": franchiseId,
    "user_id": userId,
    "menu_ids": menuIds,
    "menu_names": menuNames,
    "menu_quantities": menuQuantities,
    "total_menu_prices": totalMenuPrices,
    "name": name,
    "pickup_point": pickupPoint,
    "pickup_time": pickupTime,
    "mobile": mobile,
    "transaction_amount": transactionAmount,
    "merchant_transaction_id": merchantTransactionId,
    "wallet": wallet,
    "gst": gst,
    "pickup_date": pickupDate,
    "contact_customer": contactCustomer,
  };

  try {
    final resp = await APIService.post(
      UrlPath.biddingUrl.addFixedOrderDetails,
      data: data,
      auth: true,
      shownoInternet: true,
      console: true,
      timeout: const Duration(seconds: 30),
    );

    debugPrint("📡 [FIXED ORDER] RESPONSE: ${resp.fullBody}");

    _isLoading = false;
    notifyListeners();

    // ✅ handle partial failure (stock issue)
    if (resp.fullBody is Map<String, dynamic> &&
        resp.fullBody['success'] == false &&
        resp.fullBody['data'] != null &&
        resp.fullBody['data']['menu_id'] != null) {
      return {
        "status": "stock_error",
        "data": resp.fullBody['data'],
        "message": resp.fullBody['message'] ?? "Stock issue detected"
      };
    }

    if (resp.status) {
      final model = OrderBiddingResponse.fromJson(resp.fullBody);
      _lastResponse = model;
      return {"status": "success"};
    } else {
      return {"status": "failed", "message": resp.message ?? "Order failed"};
    }
  } catch (e) {
    debugPrint("❌ Error in placeFixedOrder: $e");
    _isLoading = false;
    notifyListeners();
    return {"status": "error", "message": e.toString()};
  }
}


  /// ✅ Reuse wallet update function
  Future<bool> updateWallet({required String wallet}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> data = {"wallet": wallet};

      final resp = await APIService.post(
        UrlPath.loginUrl.userWalletUpdate,
        data: data,
        auth: true,
        shownoInternet: true,
        console: true,
        timeout: const Duration(seconds: 30),
      );

      debugPrint("📡 [UPDATE WALLET] RESPONSE BODY: ${resp.fullBody}");

      if (resp.status) {
        errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = resp.message ?? "Wallet update failed";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint("❌ Exception in updateWallet: $e");
      errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// ✅ Fetch Payment Status (reuse)
  Future<String> fetchPaymentStatus({
    required String merchantTransactionId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url =
          "${UrlPath.biddingUrl.getPhonePeResponse}/$merchantTransactionId";
      debugPrint("🌍 [FETCH PAYMENT STATUS] URL: $url");

      final resp = await APIService.get(
        url,
        auth: true,
        shownoInternet: true,
        console: true,
        timeout: const Duration(seconds: 25),
      );

      debugPrint("📡 [PAYMENT STATUS] RESPONSE: ${resp.fullBody}");

      if (resp.status && resp.fullBody['data'] != null) {
        final model = PaymentStatusResponse.fromJson(resp.fullBody);
        _paymentStatus = model;
        errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return model.paymentStatus ?? "failed";
      } else {
        _paymentStatus = null;
        errorMessage = resp.message ?? "Failed to fetch payment status";
        _isLoading = false;
        notifyListeners();
        return "failed";
      }
    } catch (e) {
      debugPrint("❌ Exception in fetchPaymentStatus: $e");
      errorMessage = e.toString();
      _paymentStatus = null;
      _isLoading = false;
      notifyListeners();
      return "failed";
    }
  }

  /// ✅ Verify Payment and Update Wallet
  Future<bool> verifyAndUpdateWallet({
  required String merchantTransactionId,
  required String walletUsed,
}) async {
  try {
    final status = await fetchPaymentStatus(
      merchantTransactionId: merchantTransactionId,
    );

    if (status.isEmpty) return false;
    final normalized = status.toLowerCase();

    if (normalized == "success") {
      final walletValue = double.tryParse(walletUsed) ?? 0.0;

      // ✅ Only update if wallet was actually used
      if (walletValue > 0) {
        await updateWallet(wallet: walletUsed);
      }

      return true;
    } else if (normalized == "pending") {
      return false;
    } else {
      return false;
    }
  } catch (e) {
    debugPrint("❌ Error in verifyAndUpdateWallet: $e");
    return false;
  }
}

  /// ✅ Pickup Time functions (reuse)
  Future<void> getPickupTime({
  required String franchiseId,
  required String pickupDate,
}) async {
  _isPickupTimeLoading = true;
  notifyListeners();

  final url = "${UrlPath.biddingUrl.getPickupTime}/$franchiseId/$pickupDate";
  debugPrint("🌍 [PICKUP TIME] URL: $url");

  try {
    final resp = await APIService.post(
      url,
      data: {},
      auth: true,
      shownoInternet: true,
      console: true,
      timeout: const Duration(seconds: 20),
    );

    if (resp.status && resp.fullBody['data'] != null) {
      final List data = resp.fullBody['data'];
      _pickupTimes = PickupTimeModel.listFromJson(data);
      errorMessage = null;

      // ✅ Don't auto-pick first. Let user decide.
      _selectedPickupTime = null;

      debugPrint("✅ Pickup times loaded: ${_pickupTimes.length}");
    } else {
      _pickupTimes = [];
      _selectedPickupTime = null;
      errorMessage = resp.message ?? "No pickup times available";
    }
  } catch (e) {
    debugPrint("❌ Exception in getPickupTime: $e");
    _pickupTimes = [];
    _selectedPickupTime = null;
    errorMessage = e.toString();
  } finally {
    _isPickupTimeLoading = false;
    notifyListeners();
  }
}


  Future<void> reloadPickupTime(String franchiseId, String newDate) async {
    debugPrint("🔁 Reloading pickup times for $newDate");
    await getPickupTime(franchiseId: franchiseId, pickupDate: newDate);
  }
}