import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/services/api_service.dart';
import 'package:my_food_my_price/util/constant_image.dart';
import 'package:my_food_my_price/util/exception.dart';
import 'package:my_food_my_price/util/extension.dart';
import 'package:my_food_my_price/util/global.dart';
import 'package:my_food_my_price/widgets/dilogue/dilogue.dart';

class AppCupertinoDialogue extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final Function(BuildContext context)? onTap;
  final bool barrierDismissible;

  const AppCupertinoDialogue({
    super.key,
    required this.title,
    required this.content,
    required this.buttonText,
    this.onTap,
    this.barrierDismissible = true,
  });

  static Future<T?> showTimeoutException<T>(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AppCupertinoDialogue(
          title: AppGlobal.connectTimeOut,
          content: AppGlobal.timeoutWarningmsg,
          buttonText: AppGlobal.ok.toUpperCase(),
        );
      },
    );
  }

  static Future<T?> showIncorrectCredDialogue<T>(
    BuildContext context, {
    required String message,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AppCupertinoDialogue(
          title: AppGlobal.unableLogin,
          content: message,
          buttonText: AppGlobal.tryAgain,
        );
      },
    );
  }

  static Future<T?> forceLogout<T>(
    BuildContext context, {
    required String message,
    bool forceLogin = true,
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AppCupertinoDialogue(
          title: AppGlobal.oops.toUpperCase(),
          content: message,
          buttonText: AppGlobal.loginagain,
          barrierDismissible: false,
          onTap: (context) async {
            if (forceLogin) {
              await AppRouteName.login.pushAndRemoveUntil(
                context,
                (route) => false,
              );
            } else {
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String content,
    required String buttonText,
    Function(BuildContext context)? onTap,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AppCupertinoDialogue(
          title: title,
          content: content,
          buttonText: buttonText,
          onTap: onTap,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (barrierDismissible) {
          Navigator.pop(context);
        } else {
          if (kDebugMode) {
            Navigator.pop(context);
          }
        }
      },
      child: CupertinoAlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [const SizedBox(height: 15), Text(content)],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed:
                onTap != null
                    ? () {
                      onTap!(context);
                    }
                    : () {
                      Navigator.of(context).maybePop();
                    },
            child: Text(
              buttonText,
              style: TextStyle(
                color: context.colorScheme.secondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  final Future<APIResp> Function()? retry;

  const NoInternetScreen({super.key, this.retry});

  /// Shows the bottom sheet only once and retries original API if successful
  static Future<APIResp> show(
    BuildContext context, {
    required Future<APIResp> Function() retry,
  }) async {
    final data = _FunCallManager.insert();

    if (!_FunCallManager.alreadyCalled) {
      _FunCallManager.switchValue(data);

      final bool success =
          await showModalBottomSheet<bool>(
            context: context,
            backgroundColor: context.colorScheme.surface,
            isDismissible: false,
            isScrollControlled: true,
            enableDrag: false,
            useSafeArea: true,
            builder: (context) => NoInternetScreen(retry: retry),
          ) ??
          false;

      _FunCallManager.remove(data);

      if (success) return await retry();
      return APIResp(status: false, data: "Retry Cancelled");
    } else {
      _FunCallManager.remove(data);
      while (_FunCallManager.alreadyCalled) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      return await retry(); // Wait and retry
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final navigator = Navigator.of(
            context,
          ); // ✅ capture safely before await
          try {
            final hasInternet = await APIService.checkInternet();
            if (hasInternet) {
              navigator.pop(true); // ✅ use captured navigator
            } else {
              AppDialogue.toast(AppGlobal.noInternet);
            }
          } catch (_) {
            AppDialogue.toast(AppGlobal.noInternet);
          }
        }
      },

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(ConstantImageKey.noInternet),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback:
                      (bounds) => LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          context.colorScheme.primary,
                          context.colorScheme.secondary,
                        ],
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                  child: Text(
                    AppGlobal.oops.toUpperCase(),
                    style: context.textTheme.displayLarge?.copyWith(
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppGlobal.noInternet,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final result = await APIService.checkInternet();
                        if (result) {
                          Navigator.pop(context, true); // Triggers retry
                        }
                      } catch (e) {
                        AppDialogue.toast(AppGlobal.noInternet);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.elliptical(80, 80),
                          bottomLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                          bottomRight: Radius.elliptical(80, 80),
                        ),
                      ),
                    ),
                    child: Text(
                      AppGlobal.tryAgain,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FunCallManager {
  static int limitOfCalls = 1000000;
  static int apiCallCount = 0;

  static List<MapEntry<int, bool>> list = [];

  static bool get alreadyCalled {
    return list.where((element) => element.value == true).isNotEmpty;
  }

  static MapEntry<int, bool> insert() {
    if (apiCallCount > limitOfCalls) {
      apiCallCount = 0;
    }
    apiCallCount++;
    final value = MapEntry(apiCallCount, false);
    list.add(value);
    return value;
  }

  static switchValue(MapEntry<int, bool> value) {
    list =
        list
            .map(
              (entry) =>
                  entry.key == value.key ? MapEntry(value.key, true) : entry,
            )
            .toList();
  }

  static remove(MapEntry<int, bool> value) {
    list.removeWhere((element) => element.key == value.key);
  }

  // static bool checkExist(MapEntry<int,bool> value){
  //  return list.where((element) => element.key==value.key).toList().isNotEmpty;
  // }
}

class NewVersionAvailableDialogue extends StatelessWidget {
  final String newVersion;
  final String oldVersion;
  final String? apkLink;
  const NewVersionAvailableDialogue({
    super.key,
    required this.newVersion,
    required this.apkLink,
    required this.oldVersion,
  });
  static Future<T?> showTimeoutException<T>(
    BuildContext context, {
    required ForceUpdateException exception,
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return NewVersionAvailableDialogue(
          apkLink: exception.apkLink,
          newVersion: exception.newVersion,
          oldVersion: exception.oldVersion,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppGlobal.newVersionAvailable(newVersion)),
      content: Text(AppGlobal.newVersionAvailableMsg(newVersion, oldVersion)),
      actions: [
        TextButton(
          onPressed: () async {
            try {
              if (apkLink != null) {
                // ignore: deprecated_member_use
                // await launch(apkLink!);
              } else {
                Fluttertoast.showToast(msg: 'Can\'t launch app link');
              }
            } on Exception catch (_) {
              Fluttertoast.showToast(msg: 'Can\'t launch app link');
            }
          },
          child: Text(AppGlobal.ok.toUpperCase()),
        ),
      ],
    );
  }
}

class AppWarningDialogue extends StatelessWidget {
  final String title;
  final String content;

  const AppWarningDialogue({
    super.key,
    required this.title,
    required this.content,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AppWarningDialogue(
          title: AppGlobal.connectTimeOut,
          content: AppGlobal.timeoutWarningmsg,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: Text(AppGlobal.ok.toUpperCase()),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
