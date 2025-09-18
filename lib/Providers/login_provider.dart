import 'package:flutter/material.dart';
import 'package:my_food_my_price/enums/enum.dart';
import 'package:my_food_my_price/models/LoginModels/login_model.dart';
import 'package:my_food_my_price/models/LoginModels/profile_mode.dart';
import 'package:my_food_my_price/models/api_validation_model.dart';
import 'package:my_food_my_price/services/api_service.dart';
import 'package:my_food_my_price/services/device_info.dart';
import 'package:my_food_my_price/services/location_service.dart';
import 'package:my_food_my_price/services/secure_storage.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/exception.dart';
import 'package:my_food_my_price/util/global.dart';
import 'package:my_food_my_price/util/simple_stream.dart';
import 'package:my_food_my_price/util/url_path.dart';

class LoginProvider extends ChangeNotifier {
  bool isApiValidationError = false;

  Future<void> initialFetch() async {
    AppGlobal.deviceInfo = await DeviceInfoServices.getDeviceInfo();
  }

  Future<APIResp> sendOTP({required String mobile}) async {
    debugPrint("🚀 Sending OTP to: $mobile"); // 👈

    final resp = await APIService.post(
      UrlPath.loginUrl.sendOTP,
      data: {"mobile": mobile},
      shownoInternet: false,
      auth: false,
      forceLogout: false,
      console: true,
      timeout: const Duration(seconds: 30),
    );

    debugPrint(
      "✅ sendOTP Response: status=${resp.status} | data=${resp.data}",
    ); // 👈

    if (resp.status) {
      isApiValidationError = false;
      return resp;
    }

    if (resp.data == "Validation Error") {
      debugPrint("⚠️ Validation Error: ${resp.fullBody}");
      AppConstants.apiValidationModel = ApiValidationModel.fromJson(
        resp.fullBody,
      );
      isApiValidationError = true;
      notifyListeners();
      return resp;
    }

    debugPrint("❌ Throwing APIException: ${resp.data}");
    isApiValidationError = false;
    throw APIException(
      type: APIErrorType.auth,
      message: resp.data?.toString() ?? "Invalid credential. Please try again!",
    );
  }

  Future<APIResp> resendOTP({required String mobile}) async {
    final resp = await APIService.post(
      UrlPath.loginUrl.sendOTP,
      data: {"mobile": mobile},
      shownoInternet: false,
      auth: false,
      forceLogout: false,
      console: true,
      timeout: const Duration(seconds: 30),
    );

    if (resp.status) {
      isApiValidationError = false;
      return resp;
    }

    if (resp.data == "Validation Error") {
      AppConstants.apiValidationModel = ApiValidationModel.fromJson(
        resp.fullBody,
      );
      isApiValidationError = true;
      notifyListeners();
      return resp;
    }

    isApiValidationError = false;
    throw APIException(
      type: APIErrorType.auth,
      message: resp.data?.toString() ?? "Invalid credential. Please try again!",
    );
  }

  Future<APIResp> verifyOtp({
    required String mobile,
    required String otp,
    required String tokenFCM,
  }) async {
    final resp = await APIService.post(
      UrlPath.loginUrl.otpVerify,
      data: {
        "mobile": mobile.replaceAll(RegExp(r'[^0-9]'), ''),
        "otp": otp,
        "device_token": tokenFCM,
      },
      shownoInternet: false,
      auth: false,
      forceLogout: false,
      console: true,
      timeout: const Duration(seconds: 30),
    );

    if (resp.status) {
      LoginModel data = LoginModel.fromMap(resp.fullBody);

      if (data.token != null && data.token!.isNotEmpty) {
        await SecureStorageService.write(AppConstants.token, data.token!);
        await getProfile();

        /// ✅ Optional: Fetch & save location
        await LocationService.fetchAndSaveLocation();
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
            resp.data?.toString() ?? "Invalid credential. Please try again!",
      );
    }
  }

  SimpleStream<ProfileModel?> userData = SimpleStream<ProfileModel?>(null);

  Future<SimpleStream<ProfileModel?>> getProfile() async {
    final url = UrlPath.loginUrl.getProfile;

    return await APIService.basic.getStreamList<ProfileModel?>(
      data: userData,
      auth: true,
      isPost: false,
      postData: {}, // For GET, this is harmless
      refresh: () {}, // ✅ Fix for function type
      path: url,
      toJson: (resp) {
        if (resp.data is! Map<String, dynamic>) {
          throw Exception("Invalid response format");
        }

        final profile = ProfileModel.fromJson(
          resp.data as Map<String, dynamic>,
        );

        // ✅ Fix fromMap issue

        AppConstants.profile = profile;
        SecureStorageService.saveProfile(profile);

        return profile;
      },
    );
  }
}
