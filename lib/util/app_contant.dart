import 'package:flutter/material.dart';
import 'package:my_food_my_price/models/LoginModels/profile_mode.dart';
import 'package:my_food_my_price/models/api_validation_model.dart';

class AppConstants {
  static const String appName = 'MyFood MyPrice';

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  static String networkImage =
      "https://creazilla-store.fra1.digitaloceanspaces.com/cliparts/3174456/profile-clipart-xl.png";

  static const String googleApiKey = 'AIzaSyC1q5b6YQz6m_uBeE8r8R3jsK0gAdlePz0';

  static late ApiValidationModel apiValidationModel;

  static ProfileModel? profile;

  static const String token = 'token';
  static const String userId = 'user_image';
  static const String userMobile = 'user_mobile';
  static const String location = 'user_location';
  static const String state = 'user_state';
  static const String district = 'user_district';
  static const String pincode = 'user_pincode';
  static const String latitude = 'user_latitude';
  static const String longitude = 'user_longitude';
}
