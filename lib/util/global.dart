import 'package:flutter/material.dart';
import 'package:my_food_my_price/models/devie_info_model.dart';
import 'package:my_food_my_price/util/app_contant.dart';

class AppGlobal {
  static DeviceInfoModel? deviceInfo;
  static BuildContext get context => AppConstants.navigatorKey.currentContext!;
  static String noInternet = "Not Internet Connection";
  static String turnOnInternet = "Please Turn On Your Internet Connection";
  static String tryAgain = "Try Again";
  static String connectTimeOut = "Connection timeout";
  static String timeoutWarningmsg =
      "Sorry, the request took too long to process. Please try again later.";
  static String ok = "ok";
  static String unableLogin = "Unable to login";
  static String oops = "OOPS!";
  static String loginagain = "Login Again";
  static String login = "Login";
  static String serverFetchingErrorMsg =
      "Something went wrong. Please try again!";
  static String serverBusy = "Server Busy";
  static String internalServerError = "Internal Server Error!";
  static String urlNotFound = "404 - Not Found!";
  static String urlNotExistMsg =
      "This URL is not valid. Please check the url is exist or not. This message is not for production release.";
  static String refresh = "Refresh";
  static String logout = "Logout";
  static String logoutConfirmation = "Do you really want to logout?";
  static String exit = "Exit";
  static String exitConfirmation = "Do you really want to exit?";
  static String delete = "Delete";
  static String deleteConfirmation = "Do you really want to delete?";
  static String alarm = "Alarm";
  static String alarmConfirmation = "Do you really want to alarm?";
  static String invalidLogin = "Invalid login";
  static String invalidLoginConfirmation =
      "Please login again to use this application";

  static String newVersionAvailable(Object newVersion) {
    return 'New Version Available($newVersion)';
  }

  static String newVersionAvailableMsg(Object newVersion, Object oldVersion) {
    return 'You are currently using Version $oldVersion of our app. We are pleased to inform you that a new update (Version $newVersion) is now ready for download.';
  }
}