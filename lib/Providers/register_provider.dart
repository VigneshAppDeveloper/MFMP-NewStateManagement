import 'package:flutter/material.dart';
import 'package:my_food_my_price/Providers/login_provider.dart';
import 'package:my_food_my_price/enums/enum.dart';
import 'package:my_food_my_price/models/LoginModels/register_response_model.dart';
import 'package:my_food_my_price/models/api_validation_model.dart';
import 'package:my_food_my_price/services/api_service.dart';
import 'package:my_food_my_price/services/secure_storage.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/exception.dart';
import 'package:my_food_my_price/util/url_path.dart';
class RegisterProvider extends ChangeNotifier {
  bool isApiValidationError = false;

  Future<APIResp> createProfile({
    required String name,
    required String mobile,
    required String email,
    required String devieToken,
    required String referralCode,
    required LoginProvider loginProvider,
  }) async {
    final Map<String, dynamic> data = {
      "name": name,
      "mobile": mobile,
      "email": email,
      "device_token": devieToken,
      "referral_code": referralCode,
    };

    final resp = await APIService.post(
      UrlPath.loginUrl.createProfile,
      data: data,
      shownoInternet: false,
      auth: false,
      forceLogout: false,
      console: true,
      timeout: const Duration(seconds: 30),
    );

    if (resp.status) {
      final RegisterResponseModel profile = RegisterResponseModel.fromMap(
        resp.fullBody,
      );
      if (profile.token != null && profile.token!.isNotEmpty) {
        await SecureStorageService.write(AppConstants.token, profile.token!);
        await loginProvider.getProfile();

        /// ✅ Optional: Fetch & save location
      }
      return resp;
    } else if (!resp.status && resp.data == "Validation Error") {
      AppConstants.apiValidationModel = ApiValidationModel.fromJson(
        resp.fullBody,
      );
      isApiValidationError = true;
      notifyListeners();
      return resp;
    } else {
      throw APIException(
        type: APIErrorType.toast,
        message:
            resp.data?.toString() ??
            "Profile creation failed. Please try again!",
      );
    }
  }
}

