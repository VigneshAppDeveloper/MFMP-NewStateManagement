import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Validator {
  static String? validateMobile(String? value, String phoneCode) {
    if (value == null || value.isEmpty) {
      return "Please enter the mobile number";
    }

    // Basic global mobile number validation (length check)
    if (!RegExp(r'^[0-9]{6,15}$').hasMatch(value)) {
      return "Enter a valid mobile number";
    }

    // Country-specific rule for India
    if (phoneCode == '91') {
      if (!RegExp(r'^[6789]\d{9}$').hasMatch(value)) {
        return "Enter a valid Indian mobile number";
      }
      if (RegExp(r'^(\d)\1{9}$').hasMatch(value)) {
        return "Please enter a valid mobile number";
      }
    }

    return null;
  }

 

  static String? validateEmail(String? value) {
    if (value!.isEmpty) {
      return "Please enter the E-mail";
    } else if ((!RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(value))) {
      return "Please Enter a valid E-mail";
    }
    return null;
  }

  static String? validateAccountNum(String? value) {
    if (value!.length <= 25) {
      try {
        int _ = int.parse(value);
        return null;
      } catch (e) {
        return "Please enter a valid Account number.";
      }
    } else {
      return "Please enter a valid Account number.";
    }
  }

  static String? validatePin(String? value) {
    if (value!.length == 6) {
      try {
        int _ = int.parse(value);
        return null;
      } catch (e) {
        return "Please enter a valid Pincode.";
      }
    } else {
      return "Please enter a valid Pincode.";
    }
  }

  static String? notEmpty(String? value) {
    if (value == "") {
      return "Field cannot be empty";
    }
    return null;
  }

  static String? checkMatch(String? value, String original, String errorText) {
    if (value == original) {
      return null;
    }
    return errorText;
  }

  static String? validatePassword(String? passValue) {
    String patternPass =
        // r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
        "^[A-Za-z0-9!@#\$*~?/]";
    RegExp regex = RegExp(patternPass);
    if (kDebugMode) {
      print(passValue);
    }
    if (passValue!.length < 5) {
      return "Password must be more than 5 letters";
    } else if (passValue.isEmpty) {
      return "Please enter password";
    } else if (!regex.hasMatch(passValue)) {
      return "Please enter Password";
    } else {
      return null;
    }
  }

  static String? validatePan(String? value) {
   String panPattern = "[A-Z]{5}[0-9]{4}[A-Z]{1}";

    RegExp regex =  RegExp(panPattern);
    if (value!.isEmpty) {
      return "Please enter a PAN number.";
    } else if (value.length != 10) {
      return "Please enter a valid PAN number.";
    } else if (!regex.hasMatch(value)) {
      return "Please enter a valid PAN number.";
    } else {
      return null;
    }
  }

  static String? validateifsc(String? value) {
    String ifscPattern = "^[A-Z]{4}0[A-Z0-9]{6}";
    RegExp regex =  RegExp(ifscPattern);
    if (value!.isEmpty) {
      return "Please enter a IFSC Code.";
    } else if (value.length != 11) {
      return "Please enter a valid IFSC Code.";
    } else if (!regex.hasMatch(value)) {
      return "Please enter a valid IFSC Code.";
    } else {
      return null;
    }
  }

  static String? validateGst(String? value) {
    String panPattern  =
        "^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}";
    RegExp regex =  RegExp(panPattern );
    if (value!.isEmpty) {
      return "Please enter a GST number.";
    } else if (value.length != 15) {
      return "Please enter a valid GST number.";
    } else if (!regex.hasMatch(value)) {
      return "Please enter a valid GST number.";
    } else {
      return null;
    }
  }

  

}
