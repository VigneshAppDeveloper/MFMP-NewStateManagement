import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_food_my_price/custom/dual_type.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/extension.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/init_state_widget.dart';

class AppDialogue {
  static snackBar(
    BuildContext context, {
    required String content,
    bool clearOther = true,
  }) async {
    if (clearOther) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          content,
          style: Styles.textSmall(context),
          textScaler: TextScaler.linear(1.0),
        ),
      ),
    );
  }

  static Future<R> openLoadingDialogAfterClose<T, R>(
    BuildContext context, {
    required String text,
    required Future<T> Function() load,
    double? percentage,
    FutureOr<R> Function(T value)? afterComplete,
    // R Function(T value)? afterFinish,
  }) async {
    try {
      DualTypeModel? value = await showDialog<DualTypeModel>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return _LoadingDialogue(text, load: load, percentage: percentage);
        },
      );
      if (afterComplete != null) {
        if (value?.value2 != null) {
          throw value?.value2;
        }
        return await afterComplete(value?.value1);
      } else {
        if (value?.value2 != null) {
          throw value?.value2;
        } else {
          return value?.value1;
        }
      }
    } on Exception {
      rethrow;
    }
  }

  static Future<T?> alert<T>(
    BuildContext context, {
    String? title,
    String? content,
    FutureOr<T> Function()? load,
    bool singleButton = false,
    String confirmText = "Ok",
    String cancelText = "Cancel",
  }) async {
    return await showDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(102),
      builder: (context) {
        return _FlexibleAlertDialogue(
          title: title,
          content: content,
          load: load,
          singleButton: singleButton,
          confirmText: confirmText,
          cancelText: cancelText,
        );
      },
    );
  }

  static Future<T?> delete<T>(
    BuildContext context, {
    String? title,
    String? content,
    FutureOr<T> Function()? load,
  }) async {
    return await showDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(102),
      builder: (context) {
        return _FlexibleAlertDialogue(
          title: title,
          content: content,
          load: load,
          singleButton: false, // because delete should have Cancel + Ok
          confirmText: "Delete",
          cancelText: "Cancel",
        );
      },
    );
  }

  static void toast(
    String msg, {
    Duration duration = const Duration(seconds: 1),
  }) {
    Fluttertoast.showToast(msg: msg);
  }

  static void toastContext(
    BuildContext context, {
    required String msg,
    Duration? duration,
  }) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: context.colorScheme.onSurface,
      ),
      child: Text(
        msg,
        style: Styles.textExtraSmall(context,color: context.colorScheme.surface),
        textScaler: TextScaler.linear(1.0),
      ),
    );
    FToast()
        .init(context)
        .showToast(
          child: toast,
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 2),
        );
  }

  // static Future<DateTime?> showDatePickers(
  //   BuildContext context, {
  //   DateTime? initialDate,
  //   DateTime? firstDate,
  // }) async {
  //   return await showDatePicker(
  //     context: context,
  //     firstDate: firstDate ?? AppConstants.firstDate,
  //     lastDate: AppConstants.lastDate,
  //     initialDate: initialDate,
  //   );
  // }

  static Future<DateTimeRange?> showDateRangePickers(
    BuildContext context, {
    DateTimeRange? initialDateRange,
  }) async {
    return await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: context.themeData.copyWith(
            colorScheme: context.colorScheme.copyWith(
              secondaryContainer: context.colorScheme.primaryContainer,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  static Future<TimeOfDay?> timePicker(
    BuildContext context, {
    required TimeOfDay initialTime,
  }) async {
    return await showTimePicker(context: context, initialTime: initialTime);
  }
}

class _LoadingDialogue extends StatefulWidget {
    final String text;
  final double? percentage;
  final Future Function() load;
  const _LoadingDialogue(this.text,{required this.load, this.percentage});

  @override
  State<_LoadingDialogue> createState() => _LoadingDialogueState();
}

class _LoadingDialogueState extends State<_LoadingDialogue> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final navigator = Navigator.of(context);
      try {
        final result = await widget.load();
        if (mounted) {
          navigator.  pop(DualTypeModel(value1: result, value2: null));
        }
      } on Exception catch (e) {
        if (mounted) {
          navigator.pop(DualTypeModel(value1: null, value2: e));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Center(
        child: Container(
          // width: 300,
          // height: 100,
          decoration: BoxDecoration(
           color: Colors.white.withAlpha(20),

            //borderRadius: BorderRadius.circular(20),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withAlpha(60),
            //     blurRadius: 15,
            //     spreadRadius: 5,
            //   ),
            // ],
            // border: Border.all(color: Colors.white.withAlpha(40)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child:  Center(
              child: SpinKitFadingCircle(
                color: AppColor.maincolor,
                size: 50.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _FlexibleAlertDialogue<T> extends StatelessWidget {
  final String? title;
  final String? content;
  final FutureOr<T> Function()? load;
  final bool singleButton;
  final String confirmText;
  final String cancelText;

  const _FlexibleAlertDialogue({
    super.key,
    this.title,
    this.content,
    this.load,
    this.singleButton = false,
    this.confirmText = "Ok",
    this.cancelText = "Cancel",
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title != null ? Text(title!) : null,
      content: content != null ? Text(content!) : null,
      actions: [
        if (!singleButton)
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(color: context.colorScheme.secondary),
            ),
          ),
        TextButton(
          onPressed: () async {
            final navigator = Navigator.of(context); // Capture before async

            try {
              if (load != null) {
                final value = await load!();
                navigator.pop(value); // Use captured navigator
              } else {
                navigator.pop(true);
              }
            } catch (_) {
              navigator.pop(null);
              AppDialogue.toast("Something went wrong");
            }
          },

          child: Text(
            confirmText,
            style: TextStyle(color: context.colorScheme.secondary),
          ),
        ),
      ],
    );
  }
}
