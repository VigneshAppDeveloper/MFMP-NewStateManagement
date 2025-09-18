import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_food_my_price/enums/enum.dart';
import 'package:my_food_my_price/flavours.dart';
import 'package:my_food_my_price/services/api_service.dart';
import 'package:my_food_my_price/util/extension.dart';
import 'package:my_food_my_price/util/global.dart';
import 'package:my_food_my_price/util/simple_stream.dart';
import 'package:my_food_my_price/widgets/dilogue/dilogue.dart';
import 'package:my_food_my_price/widgets/dilogue/warnings.dart';

class APIException implements Exception {
  final APIErrorType type;
  final String message;

  APIException({
    this.type = APIErrorType.other,
    this.message = 'Unknown Exception',
  });

  factory APIException.fromJson(dynamic json) {
    late APIErrorType type;
    switch (json['type']?.toString().toLowerCase()) {
      case 'auth':
        type = APIErrorType.auth;
        break;
      case 'toast':
        type = APIErrorType.toast;
        break;
      case 'statusCode':
        type = APIErrorType.statusCode;
        break;
      case 'other':
        type = APIErrorType.other;
        break;
      default:
        type = APIErrorType.other;
        break;
    }
    late String msg;
    if (json['message'] is String?) {
      msg = json['message'] ?? "Something went wrong!";
    } else {
      try {
        Map<String, dynamic> value = Map<String, dynamic>.from(json['message']);
        List<String> messages = [];
        for (var element in value.values) {
          if (element is List) {
            messages.addAll((element).map((e) => e.toString()).toList());
          } else {
            messages.add(element.toString());
          }
        }
        msg = messages.join("\n");
      } on Exception {
        msg = "Something went wrong!";
      }
    }
    return APIException(type: type, message: msg);
  }

  Future<T?> showError<T>(
    BuildContext context, {
    bool forceLogin = true,
  }) async {
    switch (type) {
      case APIErrorType.auth:
        return await AppCupertinoDialogue.forceLogout(
          context,
          message: message,
          forceLogin: forceLogin,
        );
      case APIErrorType.unauthorized: // ✅ handle unauthorized same as auth
        return await AppCupertinoDialogue.forceLogout(
          context,
          message: message,
          forceLogin: forceLogin,
        );
      case APIErrorType.timeout: // ✅ new timeout case
        AppDialogue.toast(AppGlobal.timeoutWarningmsg);
        return null;
      case APIErrorType.other:
        AppDialogue.toast(AppGlobal.serverFetchingErrorMsg);
        return null;
      case APIErrorType.toast:
        AppDialogue.toast(message);
        return null;
      case APIErrorType.statusCode:
        AppDialogue.toast(AppGlobal.serverFetchingErrorMsg);
        return null;
      case APIErrorType.internalServerError:
        return await AppCupertinoDialogue.show<T>(
          context,
          title:
              F.appFlavor != Flavor.dev
                  ? AppGlobal.serverBusy
                  : AppGlobal.internalServerError,
          content:
              F.appFlavor != Flavor.dev
                  ? AppGlobal.serverFetchingErrorMsg
                  : message,
          buttonText: AppGlobal.ok.toUpperCase(),
        );
      case APIErrorType.urlNotFound:
        return await AppCupertinoDialogue.show<T>(
          context,
          title:
              F.appFlavor != Flavor.dev
                  ? AppGlobal.serverBusy
                  : AppGlobal.urlNotFound,
          content:
              F.appFlavor != Flavor.dev ? AppGlobal.urlNotExistMsg : message,
          buttonText: AppGlobal.ok.toUpperCase(),
        );
    }
  }
}

class InternetException implements Exception {
  final InternetAvailabilityType type;

  InternetException({this.type = InternetAvailabilityType.turnOnInternet});

  String get message =>
      type == InternetAvailabilityType.turnOnInternet
          ? AppGlobal.turnOnInternet
          : AppGlobal.noInternet;
}

enum PermissionType {
  locationAccess,
  locationService,
  storage,
  camera,
  openSettings,
}

class PermissionDeniedExceptions implements Exception {
  final PermissionType type;

  const PermissionDeniedExceptions(this.type);

  Future<T?> showError<T>(BuildContext context) async {
    late String value;
    switch (type) {
      case PermissionType.locationService:
        value = "Location Service";
        break;
      case PermissionType.storage:
        value = "Storage";
        break;
      case PermissionType.camera:
        value = "Camera";
        break;
      case PermissionType.locationAccess:
        value = "Location Permission";
        break;

      case PermissionType.openSettings:
        value = '';
    }
    if (type == PermissionType.openSettings) {
      return null;
    }
    return await AppWarningDialogue.show(
      context,
      title: "Permission Required!",
      content: "Please grant $value permission to use this.",
    );
  }
}

class ForceUpdateException implements Exception {
  final String newVersion;
  final String oldVersion;
  final String? apkLink;

  ForceUpdateException({
    required this.newVersion,
    required this.oldVersion,
    required this.apkLink,
  });
}

class ExceptionHandler extends StatelessWidget {
  final Object? exception;
  final void Function()? onRefresh;
  final bool dragRefresh;

  const ExceptionHandler(
    this.exception, {
    super.key,
    required this.onRefresh,
    this.dragRefresh = false,
  });

  static Future<T?> showMessage<T>(
    BuildContext context,
    Object? exception, {
    bool forceLogin = true,
  }) async {
    switch (exception.runtimeType) {
      case const (ForceUpdateException):
        exception as ForceUpdateException;
        return await NewVersionAvailableDialogue.showTimeoutException(
          context,
          exception: exception,
        );
      case const (PermissionDeniedExceptions):
        exception as PermissionDeniedExceptions;
        return await exception.showError(context);
      case const (APIException):
        exception as APIException;
        return await exception.showError(context, forceLogin: forceLogin);
      case const (FormatException):
        exception as FormatException;
        return await APIException(
          type: APIErrorType.internalServerError,
        ).showError(context);
      case const (TimeoutException):
        exception as TimeoutException;
        return await AppCupertinoDialogue.showTimeoutException(context);
      case const (InternetException):
        exception as InternetException;
        return await NoInternetScreen.show(
              context,
              retry: () async {
                // this retry doesn't really retry any API here, so just return an empty failed response
                return APIResp(status: false, data: "Retry Not Available");
              },
            )
            as T?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = Builder(
      builder: (context) {
        switch (exception.runtimeType) {
          case const (APIException):
            final value = exception as APIException;
            switch (value.type) {
              case APIErrorType.auth:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppGlobal.oops.toUpperCase(),
                        style: context.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppGlobal.serverFetchingErrorMsg,
                        textAlign: TextAlign.center,
                      ),
                      if (onRefresh != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: onRefresh,
                              child: Text(AppGlobal.refresh),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              case APIErrorType.unauthorized:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppGlobal.oops.toUpperCase(),
                        style: context.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppGlobal
                            .invalidLoginConfirmation, // ✅ tells user they need to login again
                        textAlign: TextAlign.center,
                      ),
                      if (onRefresh != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: onRefresh,
                              child: Text(AppGlobal.loginagain),
                            ),
                          ],
                        ),
                    ],
                  ),
                );

              case APIErrorType.timeout:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppGlobal.oops.toUpperCase(),
                        style: context.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppGlobal
                            .timeoutWarningmsg, // ✅ shows timeout-friendly message
                        textAlign: TextAlign.center,
                      ),
                      if (onRefresh != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: onRefresh,
                              child: Text(AppGlobal.tryAgain),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              case APIErrorType.other:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppGlobal.oops,
                        style: context.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppGlobal.serverFetchingErrorMsg,
                        textAlign: TextAlign.center,
                      ),
                      if (onRefresh != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: onRefresh,
                              child: Text(AppGlobal.refresh),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              case APIErrorType.toast:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppGlobal.oops,
                        style: context.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(value.message, textAlign: TextAlign.center),
                      if (onRefresh != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: onRefresh,
                              child: Text(AppGlobal.refresh),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              case APIErrorType.statusCode:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppGlobal.oops,
                        style: context.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppGlobal.serverFetchingErrorMsg,
                        textAlign: TextAlign.center,
                      ),
                      if (onRefresh != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: onRefresh,
                              child: Text(AppGlobal.refresh),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              case APIErrorType.internalServerError:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppGlobal.oops,
                        style: context.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppGlobal.serverFetchingErrorMsg,
                        textAlign: TextAlign.center,
                      ),
                      if (onRefresh != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: onRefresh,
                              child: Text(AppGlobal.refresh),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              case APIErrorType.urlNotFound:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppGlobal.urlNotFound,
                        style: context.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppGlobal.urlNotExistMsg,
                        textAlign: TextAlign.center,
                      ),
                      if (onRefresh != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: onRefresh,
                              child: Text(AppGlobal.refresh),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
            }
          case const (FormatException):
            exception as FormatException;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(AppGlobal.oops, style: context.textTheme.headlineLarge),
                  const SizedBox(height: 10),
                  Text(
                    AppGlobal.serverFetchingErrorMsg,
                    textAlign: TextAlign.center,
                  ),
                  if (onRefresh != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: onRefresh,
                          child: Text(AppGlobal.refresh),
                        ),
                      ],
                    ),
                ],
              ),
            );
          case const (TimeoutException):
            exception as TimeoutException;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(AppGlobal.oops, style: context.textTheme.headlineLarge),
                  const SizedBox(height: 10),
                  Text(
                    AppGlobal.timeoutWarningmsg,
                    textAlign: TextAlign.center,
                  ),
                  if (onRefresh != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: onRefresh,
                          child: Text(AppGlobal.refresh),
                        ),
                      ],
                    ),
                ],
              ),
            );
          case const (InternetException):
            exception as InternetException;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(AppGlobal.oops, style: context.textTheme.headlineLarge),
                  const SizedBox(height: 10),
                  Text(AppGlobal.noInternet, textAlign: TextAlign.center),
                  if (onRefresh != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: onRefresh,
                          child: Text(AppGlobal.refresh),
                        ),
                      ],
                    ),
                ],
              ),
            );
          default:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(AppGlobal.oops, style: context.textTheme.headlineLarge),
                  const SizedBox(height: 10),
                  Text(
                    AppGlobal.serverFetchingErrorMsg,
                    textAlign: TextAlign.center,
                  ),
                  if (onRefresh != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: onRefresh,
                          child: Text(AppGlobal.refresh),
                        ),
                      ],
                    ),
                ],
              ),
            );
        }
      },
    );
    return dragRefresh ? AppRefreshableWidget(child: widget) : widget;
  }
}
