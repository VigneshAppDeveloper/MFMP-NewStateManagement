import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Helper {
  late BuildContext context;
  late DateTime currentBackPressTime;
  Helper.of(this.context);
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void goBack(dynamic result) {
    Navigator.pop(context, result);
  }

  bool predicate(Route<dynamic> route) {
    if (kDebugMode) {
      print(route);
    }
    return false;
  }

  Widget loader() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
        backgroundColor: Colors.grey[300],
      ),
    );
  }

  String capitalizeFirst(String s) => s[0].toUpperCase() + s.substring(1);
  String capitalizeFirstOnly(String s) => s[0].toUpperCase();

  String getNewLineString(List<String> data) {
    StringBuffer sb = StringBuffer(); // ✅ removed `new`
    for (String line in data) {
      sb.write("$line\n");
    }
    return sb.toString();
  }

  Color color(String data) {
    int colorData = int.parse("0xff$data");

    return Color(colorData);
  }

  String showDate(String date) {
    var formatter = DateFormat('dd-MM-yyyy');
    DateTime df = DateTime.parse(date);
    String returnDate = formatter.format(df);
    return returnDate;
  }

  String calendarDate(String date) {
    var formatter = DateFormat('yyyy-MM-dd');
    DateTime df = DateTime.parse(date);
    String returnDate = formatter.format(df);
    return returnDate;
  }

  static void setPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static void setAllOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  TimeOfDay parseTimeOfDay(String t) {
    DateTime dateTime = DateFormat("HH:mm").parse(t);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }
}
