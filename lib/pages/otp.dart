import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/Providers/login_provider.dart';
import 'package:my_food_my_price/components/button.dart';
import 'package:my_food_my_price/helpers/helper.dart';
import 'package:my_food_my_price/models/LoginModels/login_model.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/services/secure_storage.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/constant_image.dart';
import 'package:my_food_my_price/util/exception.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/dilogue/dilogue.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:provider/provider.dart';

class Otp extends StatefulWidget {
  const Otp({super.key});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp>  {
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController otp = TextEditingController();
  TextEditingController mobile = TextEditingController();
  late Timer _timer;
  int _start = 90;
  late Helper hp;
  bool haserror = false;
  bool isLoading = false;
  String? tokenFCM;
  LoginProvider get loginProvider => context.read<LoginProvider>();

  @override
  void initState() {
    super.initState();
    startTimer();
    // listenOtp();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getdata();
      await Future.delayed(const Duration(milliseconds: 500));
      await getToken();
      // getAppSignature();
      // codeUpdated();
    });
  }

  // void listenOtp() async {
  //   try {
  //     if (Platform.isAndroid) {
  //       final deviceInfo = DeviceInfoPlugin();
  //       final androidInfo = await deviceInfo.androidInfo;
  //       final brand = androidInfo.brand?.toLowerCase();

  //       // ✅ Disable for buggy ROMs
  //       if (brand?.contains("samsung") == true ||
  //           brand?.contains("realme") == true) {
  //         debugPrint("⚠️ SMS auto-retrieval disabled for $brand");
  //         return;
  //       }
  //     }

  //     await SmsAutoFill().listenForCode();
  //   } catch (e, st) {
  //     debugPrint("⚠️ SmsAutoFill listen failed: $e");
  //   }
  // }

  // @override
  // void codeUpdated() async {
  //   final codeStream = SmsAutoFill().code;
  //   final receivedCode = await codeStream.first;

  //   //print("Auto-filled OTP: $receivedCode");

  //   if (!mounted) return;
  //   if (receivedCode.isNotEmpty) {
  //     setState(() {
  //       otp.text = receivedCode;
  //     });
  //     _verifyOtpAutomatically(); // ✅ Submit after autofill
  //   }
  // }

  String maskMobileNumber(String number) {
    if (number.length >= 10) {
      return '******${number.substring(6)}';
    }
    return number;
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  Future<void> getdata() async {
    final storedMobile = await SecureStorageService.read(
      AppConstants.userMobile,
    );
    mobile.text = storedMobile ?? '';

    if (kDebugMode) {
      print("Retrieved mobile number: ${mobile.text}");
    }
  }

  Future<void> getToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken().timeout(
        const Duration(seconds: 10),
      );

      if (!mounted) return;
      if (token != null && token.isNotEmpty) {
        tokenFCM = token;
        if (kDebugMode) debugPrint("✅ FCM Token fetched: $tokenFCM");
      } else {
        if (kDebugMode) debugPrint("⚠️ FCM token is null or empty");
        tokenFCM = "";
      }
    } on TimeoutException {
      if (kDebugMode) debugPrint("⚠️ FCM token request timed out");
      tokenFCM = "";
    } on FirebaseException catch (e) {
      if (kDebugMode)
        debugPrint("⚠️ Firebase token error: ${e.code} - ${e.message}");
      tokenFCM = "";
    } catch (e) {
      if (kDebugMode) debugPrint("❌ Unexpected FCM token error: $e");
      tokenFCM = "";
    }
  }

  // void getAppSignature() async {
  //   String signature = await SmsAutoFill().getAppSignature;
  //   if (kDebugMode) print("App Signature: $signature");
  // }

  // void _verifyOtpAutomatically() async {
  //   FocusScope.of(context).unfocus();

  //   if (otp.text.length == 4) {
  //     try {
  //       await AppDialogue.openLoadingDialogAfterClose(
  //         context,
  //         text: "Verify...",
  //         load: () async {
  //           return await loginProvider.verifyOtp(
  //             mobile: mobile.text,
  //             otp: otp.text,
  //             tokenFCM: tokenFCM ?? "",
  //             context: context,
  //           );
  //         },
  //         afterComplete: (resp) async {
  //           if (!mounted) return;

  //           if (resp.status) {
  //             LoginModel baseModel = LoginModel.fromMap(resp.fullBody);

  //             if (baseModel.message == "OTP verified successfully") {
  //               if (!mounted) return;
  //               await AppRouteName.appPage.pushAndRemoveUntil(
  //                 context,
  //                 (route) => false,
  //               );
  //             } else if (baseModel.message == "Not registered") {
  //               if (!mounted) return;
  //               await AppRouteName.introPage.push(context);
  //             } else {
  //               if (!mounted) return;
  //               AppDialogue.toast("Unexpected response: ${baseModel.message}");
  //             }
  //           }
  //         },
  //       );
  //     } on Exception catch (e) {
  //       if (!mounted) return;
  //       ExceptionHandler.showMessage(context, e);
  //     }
  //   }
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    //cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ConstantImageKey.loginBg),
                fit: BoxFit.fill,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: height / 20),
                      Image.asset(
                        'assets/icons/otp.png',
                        height: 120,
                        width: 120,
                      ),
                      SizedBox(height: height / 30),
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'VERIFICATION CODE'.toUpperCase(),
                                style: Styles.textStyleExtraLarge(
                                  context,
                                  color: AppColor.maincolor,
                                ),
                                children: <TextSpan>[],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height / 30),
                      Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: 'Enter the Otp Sent to  ',
                                  style: Styles.textStyleLarge(
                                    context,
                                    color: AppColor.hintTextColor,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: maskMobileNumber(mobile.text),
                                      style: Styles.textStyleLarge(
                                        context,
                                        color: AppColor.hintTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height / 30),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Align(
                          // alignment: Alignment.topCenter,
                          child: MediaQuery(
                            data: MediaQuery.of(
                              context,
                            ).copyWith(textScaler: TextScaler.linear(1.0)),
                            child: PinCodeTextField(
                              pinBoxHeight: 65,
                              pinBoxWidth: 65,
                              pinBoxRadius: 10,
                              autofocus: true,
                              controller: otp,
                              hideCharacter: true,
                              highlight: true,
                              highlightColor: Colors.black,
                              defaultBorderColor: Colors.grey.shade300,
                              hasTextBorderColor: Colors.black,
                              errorBorderColor: Colors.red,
                              maxLength: 4,
                              hasError: haserror,
                              maskCharacter: "*", //😎
                              onTextChanged: (text) {},
                              onDone: (text) async {},
                              wrapAlignment: WrapAlignment.spaceEvenly,
                              pinBoxDecoration:
                                  ProvidedPinBoxDecoration
                                      .roundedPinBoxDecoration,
                              pinTextStyle: const TextStyle(
                                fontSize: 37.0,
                                color: Colors.black,
                              ),
                              pinTextAnimatedSwitcherTransition:
                                  ProvidedPinBoxTextAnimation.scalingTransition,
                              pinBoxColor: Colors.white,
                              pinTextAnimatedSwitcherDuration: const Duration(
                                milliseconds: 300,
                              ),

                              highlightAnimationBeginColor: Colors.red,
                              highlightAnimationEndColor: Colors.white12,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height / 30),
                      GestureDetector(
                        onTap:
                            _start == 0
                                ? () async {
                                  setState(() => _start = 90);
                                  startTimer();
                                  try {
                                    await AppDialogue.openLoadingDialogAfterClose(
                                      context,
                                      text: "Resending OTP...",
                                      load:
                                          () => loginProvider.resendOTP(
                                            mobile: mobile.text,
                                          ),
                                      afterComplete: (resp) {
                                        if (resp.status) {
                                          AppDialogue.toast(
                                            resp.data ?? "OTP resent",
                                          );
                                        }
                                      },
                                    );
                                  } on Exception catch (e) {
                                    ExceptionHandler.showMessage(context, e);
                                  }
                                }
                                : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Resend Code !",
                              style: Styles.textStyleMedium(
                                context,
                                color:
                                    _start == 0
                                        ? Color.fromARGB(255, 219, 7, 7)
                                        : Colors.grey,
                              ),
                              textScaler: TextScaler.linear(1.0),
                              textAlign: TextAlign.center,
                            ),
                            if (_start > 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '($_start s)',
                                  style: Styles.textStyleMedium(
                                    context,
                                    color: AppColor.maincolor,
                                  ),
                                  textScaler: TextScaler.linear(1.0),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: height / 30),
                      MyButton(
                        text:
                            isLoading
                                ? 'Loading...'
                                : "Verify otp".toUpperCase(),
                        textcolor: AppColor.whiteColor,
                        textsize: 20 * (width / 375),
                        fontWeight: FontWeight.w600,
                        letterspacing: 0.7,
                        buttoncolor: AppColor.maincolor,

                        buttonheight: 52 * (height / 812),
                        buttonwidth: width,
                        radius: 20,
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          if (otp.text.length == 4) {
                            try {
                              await AppDialogue.openLoadingDialogAfterClose(
                                context,
                                text: "Verify...",
                                load: () async {
                                  return await loginProvider.verifyOtp(
                                    mobile: mobile.text,
                                    otp: otp.text,
                                    tokenFCM: tokenFCM ?? "",
                                    context: context,
                                  );
                                },
                                afterComplete: (resp) async {
                                  if (!mounted) return;
                                  LoginModel baseModel = LoginModel.fromMap(
                                    resp.fullBody,
                                  );
                                  if (baseModel.message.toLowerCase() ==
                                      "otp verified successfully"
                                          .toLowerCase()) {
                                    await AppRouteName.appPage
                                        .pushAndRemoveUntil(
                                          context,
                                          (route) => false,
                                        );
                                  } else if (baseModel.message.toLowerCase() ==
                                      "not registered") {
                                    await AppRouteName.registerPage.push(
                                      context,
                                    );
                                  } else {
                                    AppDialogue.toast(
                                      "Unexpected response: ${baseModel.message}",
                                    );
                                  }
                                },
                              );
                            } on Exception catch (e) {
                              if (context.mounted) {
                                ExceptionHandler.showMessage(context, e);
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
