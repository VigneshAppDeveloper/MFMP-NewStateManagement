import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_food_my_price/models/LoginModels/profile_mode.dart';
import 'package:my_food_my_price/models/app_state_model.dart';
import 'package:my_food_my_price/util/app_contant.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage();

  static Future<void> write(String key, String value) async =>
      await _storage.write(key: key, value: value);

  static Future<String?> read(String key) async =>
      await _storage.read(key: key);

  static Future<void> delete(String key) async =>
      await _storage.delete(key: key);

  static Future<void> clearAll() async => await _storage.deleteAll();

  static Future<AppStateModel> getUserAppState() async {
    final values = await Future.wait([
      read(AppConstants.token),
      read('is_first_register'),
      read('state_id'),
      read('district_id'),
    ]);

    return AppStateModel(
      token: values[0],
      isFirstRegister: values[1],
      stateId: values[2],
      districtId: values[3],
    );
  }

  static Future<void> saveProfile(ProfileModel profile) async {
    await write('user_profile', jsonEncode(profile.toJson()));
  }

  static Future<ProfileModel?> readProfile() async {
    final json = await read('user_profile');
    if (json == null) return null;

    try {
      final map = jsonDecode(json);
      return ProfileModel.fromJson(map);
    } catch (e) {
      debugPrint("❌ Failed to decode profile: $e");
      return null;
    }
  }

  static Future<void> clearAllAppData() async {
    await SecureStorageService.clearAll();
    AppConstants.profile = null;
    // if needed
    // Clear any other AppConstants here
  }


   static const _googleApiKeyKey = 'AIzaSyC1q5b6YQz6m_uBeE8r8R3jsK0gAdlePz0';

  static Future<void> saveGoogleApiKey(String apiKey) async {
    await write(_googleApiKeyKey, apiKey);
  }

  static Future<String?> readGoogleApiKey() async {
    return await read(_googleApiKeyKey);
  }

  static Future<void> deleteGoogleApiKey() async {
    await delete(_googleApiKeyKey);
  }
}
