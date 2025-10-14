import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_food_my_price/util/styles.dart';


class Dialogs {
  static snackbar(String message, context, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: isError ? Colors.red : Colors.green,
      elevation: 5,
      content: Text(
        message,
        style: Styles.textStyleMedium(
          color: Colors.white,
          context,
        ),
        textScaler: TextScaler.linear(1.0),
      ),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      animation: AlwaysStoppedAnimation<double>(1),
      dismissDirection: DismissDirection.horizontal,
    ));
  }

  static snackbar1(String message, context, {bool isError = false}) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   backgroundColor: isError ? Colors.red : Colors.green,
    //   elevation: 5,
    //   content: Text(
    //     message,
    //     style: Styles.textStyleMedium(color: Colors.white),
    //   ),
    //   duration: const Duration(seconds: 2),
    //   behavior: SnackBarBehavior.floating,
    //   margin: const EdgeInsets.all(10),
    //   // animation: AlwaysStoppedAnimation<double>(1),
    //   dismissDirection: DismissDirection.horizontal,
    // ));
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: isError ? Colors.red : Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static toast(String message, context,
      {bool isError = true, bool isnormal = false}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: isnormal
            ? Colors.white
            : isError
                ? Colors.red
                : Colors.green,
        textColor: isnormal ? Colors.black : Colors.white,
        fontSize: 16.0);
  }
}
