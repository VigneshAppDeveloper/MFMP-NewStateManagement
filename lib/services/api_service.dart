import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:my_food_my_price/config/app_config.dart';
import 'package:my_food_my_price/enums/enum.dart';
import 'package:my_food_my_price/services/dio_clinet.dart';
import 'package:my_food_my_price/services/secure_storage.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/exception.dart';
import 'package:my_food_my_price/util/global.dart';
import 'package:my_food_my_price/util/simple_stream.dart';
import 'package:my_food_my_price/widgets/dilogue/dilogue.dart';
import 'package:my_food_my_price/widgets/dilogue/warnings.dart';

class _Basic {
  const _Basic();
  Future<SimpleStream<T>> getStreamList<T>({
    required SimpleStream<T> data,
    required void Function() refresh,
    required String path,
    Object? postData,
    Map<String, String>? params,
    required T Function(APIResp data) toJson,
    bool console = true,
    bool forceLogout = true,
    bool auth = true,
    bool shownoInternet = true,
    Duration? timeout,
    bool isPost = false,
  }) async {
    data.addLoading(true);
    refresh();
    try {
      final resp =
          isPost
              ? await APIService.post(
                path,
                data: postData,
                console: console,
                params: params,
                timeout: timeout,
                shownoInternet: shownoInternet,
                auth: auth,
                forceLogout: forceLogout,
              )
              : await APIService.get(
                path,
                // data: postData,
                console: console,
                params: params,
                timeout: timeout,
                shownoInternet: shownoInternet,
                auth: auth,
                forceLogout: forceLogout,
              );
      if (resp.status) {
        data.add(toJson(resp));
        refresh();
        return data;
      } else {
        data.addError(resp.data?.toString() ?? 'Unknown Error');
        refresh();
        return data;
      }
    } on Exception catch (e) {
      data.addError(e);
      refresh();
      rethrow;
    }
  }

  Future<PaginationStream<T>> getStreamListPagination<T>({
    required PaginationStream<T> data,
    bool reload = false,
    required void Function() refresh,
    required String path,
    Object? postData,
    bool isPost = false,
    Map<String, String>? params,
    required List<T> Function(APIResp data) toJson,
    bool console = true,
    bool auth = true,
    bool forceLogout = true,
    bool shownoInternet = true,
    Duration? timeout,
    CancelToken? cancelToken,
  }) async {
    if (reload) {
      data.clear();
    }
    data.addLoading(true);
    refresh();
    try {
      final resp =
          isPost
              ? await APIService.post(
                path,
                console: console,
                params: params,
                data: postData,
                forceLogout: forceLogout,
                auth: auth,
                shownoInternet: shownoInternet,
                timeout: timeout,
              )
              : await APIService.get(
                path,
                console: console,
                params: params,
                forceLogout: forceLogout,
                auth: auth,
                shownoInternet: shownoInternet,
                timeout: timeout,
                data: postData,
                cancelToken: cancelToken,
              );
      if (resp.status == RespStatus.pass) {
        data.add(toJson(resp));
        refresh();
        return data;
      } else {
        data.addError(resp.data?.toString() ?? 'Unknown Error');
        refresh();
        return data;
      }
    } on Exception catch (e) {
      data.addError(e);
      refresh();
      rethrow;
    }
  }

  Future<T?> getData<T>({
    required String path,
    Map<String, String>? params,
    required T Function(APIResp data) toJson,
    Duration? timeout,
    bool shownoInternet = true,
    bool auth = true,
    bool console = true,
    bool forceLogout = true,
  }) async {
    try {
      final resp = await APIService.get(
        path,
        params: params,
        timeout: timeout,
        shownoInternet: shownoInternet,
        auth: auth,
        console: console,
        forceLogout: forceLogout,
      );
      if (resp.status == RespStatus.pass) {
        return toJson(resp);
      } else {
        return null;
      }
    } on Exception {
      rethrow;
    }
  }

  Future<T?> getPostData<T>({
    required String path,
    Map<String, String>? params,
    required Object? data,
    required T Function(APIResp data) toJson,
    Duration? timeout,
    bool shownoInternet = true,
    bool auth = true,
    bool console = true,
    bool forceLogout = true,
  }) async {
    try {
      final resp = await APIService.post(
        path,
        data: data,
        // params: params,
        timeout: timeout,
        shownoInternet: shownoInternet,
        auth: auth,
        console: console,
        forceLogout: forceLogout,
      );

      if (resp.status) {
        return toJson(resp);
      } else {
        return null;
      }
    } on Exception {
      rethrow;
    }
  }

  Future<bool> success<T>({
    required String path,
    required Object? data,
    bool avoidToast = false,
    Map<String, String>? params,
    Duration? timeout,
    bool shownoInternet = true,
    bool auth = true,
    bool console = true,
    bool forceLogout = true,
    bool isPost = true,
  }) async {
    try {
      final resp =
          data != null && isPost
              ? await APIService.post(
                path,
                data: data,
                console: console,
                auth: auth,
                shownoInternet: shownoInternet,
                timeout: timeout,
                forceLogout: forceLogout,
                params: params,
              )
              : data != null && !isPost
              ? await APIService.get(
                path,
                data: data,
                console: console,
                auth: auth,
                shownoInternet: shownoInternet,
                timeout: timeout,
                forceLogout: forceLogout,
                params: params,
              )
              : await APIService.get(
                path,
                forceLogout: forceLogout,
                params: params,
                timeout: timeout,
                shownoInternet: shownoInternet,
                auth: auth,
                console: console,
              );

      if (resp.status == RespStatus.pass) {
        if (!avoidToast) {
          AppDialogue.snackBar(
            AppGlobal.context,
            content: resp.data?.toString() ?? 'Success',
          );
        }
        return true;
      } else {
        if (!avoidToast) {
          AppDialogue.snackBar(
            AppGlobal.context,
            content: resp.data?.toString() ?? 'Error',
          );
        }
        return false;
      }
    } on Exception {
      rethrow;
    }
  }
}

class APIService {
  static const _Basic basic = _Basic();
  APIService();
  static Future<APIResp> post(
    String path, {
    required Object? data,
    bool console = true,
    bool auth = true,
    bool shownoInternet = true,
    Duration? timeout,
    Map<String, String>? params,
    bool forceLogout = true,
  }) async {
    return await _callAPI(
      path,
      data: data,
      params: params,
      isPost: true,
      console: console,
      auth: auth,
      shownoInternet: shownoInternet,
      timeout: timeout,
      forceLogout: forceLogout,
    );
  }

  static Future<APIResp> get(
    String path, {
    bool console = true,
    Map<String, String>? params,
    bool auth = true,
    bool shownoInternet = true,
    Duration? timeout,
    bool forceLogout = true,
    Object? data,
    CancelToken? cancelToken,
  }) async {
    return await _callAPI(
      path,
      data: data,
      isPost: false,
      cancelToken: cancelToken,
      console: console,
      auth: auth,
      params: params,
      shownoInternet: shownoInternet,
      timeout: timeout,
      forceLogout: forceLogout,
    );
  }

  static Future<APIResp> noInternetDialogue(
    String path, {
    bool isPost = false,
    Object? data,
    bool console = true,
    bool auth = true,
    bool shownoInternet = true,
    Duration? timeout,
    Map<String, String>? params,
    bool forceLogout = true,
  }) async {
    return await NoInternetScreen.show(
      AppGlobal.context,
      retry:
          () =>
              isPost
                  ? post(
                    path,
                    data: data,
                    console: console,
                    auth: auth,
                    shownoInternet: shownoInternet,
                    params: params,
                    timeout: timeout,
                    forceLogout: forceLogout,
                  )
                  : get(
                    path,
                    console: console,
                    auth: auth,
                    shownoInternet: shownoInternet,
                    params: params,
                    timeout: timeout,
                    forceLogout: forceLogout,
                  ),
    );
  }

  static Future<bool> checkConnectivity() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (!(connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi))) {
      return false;
    } else {
      bool result = await InternetConnection().hasInternetAccess;
      if (result == true) {
        return true;
      } else {
        return false;
      }
    }
  }

  static Future<bool> checkInternet() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (!(connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi))) {
      throw InternetException(type: InternetAvailabilityType.turnOnInternet);
    }

    bool result = await InternetConnection().hasInternetAccess;
    if (result == true) {
      return true;
    } else {
      throw InternetException(type: InternetAvailabilityType.noInternet);
    }
  }

  static Future<APIResp> _callAPI(
    String path, {
    isPost = false,
    Map<String, String>? params,
    Object? data,
    bool console = true,
    bool auth = true,
    bool shownoInternet = true,
    Duration? timeout,
    bool forceLogout = true,
    CancelToken? cancelToken,
  }) async {
    // String? token;
    params ??= {};
    console = kDebugMode && console;

    final String urls = "${AppConfig.instance.baseUrl}$path";
    Uri uri = Uri.parse(urls).replace(queryParameters: params);
    debugPrint("🌍 Calling URL: $uri");
    debugPrint("🌍 Method: ${isPost ? 'POST' : 'GET'}");
    debugPrint("🌍 Payload: $data");

    if (console) {}

    if (auth) {
      String? token = await SecureStorageService.read(AppConstants.token);

      if (token == null || token.isEmpty) {
        await logoutUser();
        return APIResp(
          status: false,
          data: "Token missing. Please log in again.",
        );
      }
    }

    final connection = await checkConnectivity();
    if (!connection) {
      return await NoInternetScreen.show(
        AppGlobal.context,
        retry:
            () => _callAPI(
              path,
              isPost: isPost,
              params: params,
              data: data,
              console: console,
              auth: auth,
              shownoInternet: shownoInternet,
              timeout: timeout,
              forceLogout: forceLogout,
              cancelToken: cancelToken,
            ),
      );
    }
    // Internet check
    final hasInternet = await checkConnectivity();
    if (!hasInternet) {
      return await NoInternetScreen.show(
        AppGlobal.context,
        retry:
            () => _callAPI(
              path,
              isPost: isPost,
              params: params,
              data: data,
              console: console,
              auth: auth,
              shownoInternet: shownoInternet,
              timeout: timeout,
              forceLogout: forceLogout,
              cancelToken: cancelToken,
            ),
      );
    }
    try {
      final dio = DioClient.instance;
      debugPrint("🚀 Dio instance ready - making request...");
      final respFun =
          isPost
              ? dio.post(uri.toString(), cancelToken: cancelToken, data: data)
              : dio.get(
                uri.toString(),
                cancelToken: cancelToken,
                queryParameters: params,
              );

      Response resp =
          await (timeout != null ? respFun.timeout(timeout) : respFun);
      debugPrint("📡 RESPONSE STATUS: ${resp.statusCode}");
      debugPrint("📡 RAW RESPONSE DATA: ${resp.data}");

      if (resp.statusCode == 200) {
        debugPrint("📡 RESPONSE STATUS: ${resp.statusCode}");
        debugPrint("📡 RAW RESPONSE DATA: ${resp.data}");

        return APIResp.fromJson(resp.data);
      } else if (resp.statusCode == 404) {
        await logoutUser();
        return APIResp(status: false, data: 'User not found or inactive');
      } else {
        throw APIException(
          type: APIErrorType.statusCode,
          message: "Unexpected status: ${resp.statusCode}",
        );
      }
    } on DioException catch (e) {
      debugPrint("❌ DIO EXCEPTION CAUGHT");
      debugPrint("❌ Status Code: ${e.response?.statusCode}");
      debugPrint("❌ Response Data: ${e.response?.data}");
      debugPrint("❌ Error Message: ${e.message}");
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw APIException(
          type: APIErrorType.timeout,
          message: "Request timed out",
        );
      }
      if (e.response?.statusCode == 401) {
        await logoutUser();
        throw APIException(
          type: APIErrorType.unauthorized,
          message: "Session expired. Please log in again.",
        );
      } else if (e.response?.statusCode == 404) {
        throw APIException(
          type: APIErrorType.urlNotFound,
          message: "Resource not found",
        );
      } else if (e.response?.statusCode == 422) {
        final errorData = e.response?.data;
        debugPrint("⚠️ Validation Error: $errorData");

        String combinedMessage = "Validation error";

        if (errorData is Map) {
          final msg = errorData['message'];
          if (msg is Map) {
            // When message is a map like: {email: [...], mobile: [...]}
            combinedMessage = msg.values.expand((v) => v).join("\n");
          } else if (msg is String) {
            // When message is a plain string like: "Invalid referral code."
            combinedMessage = msg;
          }
        }

        throw APIException(type: APIErrorType.toast, message: combinedMessage);
      }

      // else if (e.response?.statusCode == 422) {
      //   final errorData = e.response?.data;
      //   debugPrint("⚠️ Validation Error: $errorData");
      //   throw APIException(
      //     type: APIErrorType.toast,
      //     message:
      //         errorData['messages'] ?? errorData['message'] ?? "Validation error",
      //   );
      // }

      throw APIException(type: APIErrorType.other, message: e.toString());
    } catch (e) {
      throw APIException(type: APIErrorType.other, message: e.toString());
    }
  }

  static bool _isLoggingOut = false;

  static Future<void> logoutUser() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    await SecureStorageService.clearAll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = Navigator.of(AppGlobal.context, rootNavigator: true);
      if (navigator.mounted) {
        navigator.pushNamedAndRemoveUntil('/login', (route) => false);
      }
      _isLoggingOut = false;
    });
  }
}

class APIResp {
  final bool status;
  final int? statusCode;
  final dynamic data;
  final dynamic fullBody;

  factory APIResp.fromJson(dynamic json) {
    debugPrint("📥 API RAW RESPONSE: $json");
    // ✅ check for both 'status' & 'success'
    final rawStatus = json['status'] ?? json['success'];

    bool parsedStatus;
    if (rawStatus is bool) {
      parsedStatus = rawStatus;
    } else if (rawStatus is int) {
       parsedStatus = rawStatus == 1 || rawStatus == 200;
    } else if (rawStatus is String) {
      parsedStatus =
          rawStatus.toLowerCase() == 'success' || rawStatus == 'true';
    } else {
      parsedStatus = false;
    }
      dynamic parsedData;
    if (json.containsKey('data') && json['data'] != null) {
      parsedData = json['data'];
    } else if (json.containsKey('results') && json['results'] != null) {
      parsedData = json['results'];
      parsedStatus = true; // treat as valid even if no 'status' key
    } else if (json.containsKey('message')) {
      parsedData = json['message'];
    }
    debugPrint("✅ Parsed Status: $parsedStatus"); // 👈 add this
    debugPrint("✅ Data: ${json['data']} | Message: ${json['message']}");
    return APIResp(
      status: parsedStatus,
      data: json['data'] ?? json['message'],
      fullBody: json,
    );
  }

  APIResp({this.status = false, this.data, this.fullBody, this.statusCode});

  String? get message {
    if (fullBody is Map<String, dynamic>) {
      final msg = fullBody['message'];
      return msg is String ? msg : null;
    }
    return null;
  }
}

enum RespStatus { pass, fail }

extension APIRespExt on APIResp {
  T map<T>(T Function(dynamic e) param0) {
    return param0(data);
  }

  List<T> mapList<T>(T Function(dynamic e) param0) {
    return (data as List).map((e) => param0(e)).toList();
  }
}
