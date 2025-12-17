import 'dart:math';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/Providers/login_provider.dart';
import 'package:my_food_my_price/components/button.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/services/secure_storage.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/constant_image.dart';
import 'package:my_food_my_price/util/exception.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/util/validator.dart';
import 'package:my_food_my_price/widgets/dilogue/dilogue.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController mobile = TextEditingController();
  bool isLoading = false;
  bool isManualInput = false;
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(width, 2) + pow(height, 2));

  LoginProvider get loginProvider => context.read<LoginProvider>();
  String _selectedPhoneCode = "91";
  String _selectedFlag = "🇮🇳";

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
                child: Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SizedBox(height: height / 10),
                        Image.asset("assets/icons/MFMP-logo-1.jpg", width: 400),
                        SizedBox(height: height / 10),
                        Row(
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text:
                                        'Enter your mobile number to continue',
                                    style: Styles.textStyleMedium(
                                      context,
                                      color: AppColor.blackColor,
                                    ),
                                    children: <TextSpan>[],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height / 30),

                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: .5,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    showCountryPicker(
                                      context: context,
                                      showPhoneCode: true,
                                      onSelect: (Country country) {
                                        setState(() {
                                          _selectedPhoneCode =
                                              country.phoneCode;
                                          _selectedFlag = country.flagEmoji;
                                        });
                                      },
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedFlag,
                                        style: const TextStyle(fontSize: 20),
                                        textScaler: TextScaler.linear(1.0),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '+$_selectedPhoneCode',
                                        style: Styles.textStyleMedium(context),
                                        textScaler: TextScaler.linear(1.0),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                        textScaler: TextScaler.linear(1.0),
                                      ),
                                      child: TextFormField(
                                        cursorColor: Colors.grey,
                                        textAlign: TextAlign.center,
                                        controller: mobile,
                                        obscureText: false,
                                        validator:
                                            (value) => Validator.validateMobile(
                                              value,
                                              _selectedPhoneCode,
                                            ),
                                        keyboardType: TextInputType.number,
                                        // readOnly: !isManualInput,
                                        // onTap: () async {
                                        //   setState(() => isLoading = true);
                                        //   await getPhoneNumbers();
                                        //   setState(() => isLoading = false);
                                        // },
                                        decoration: InputDecoration(
                                          hintText: 'Mobile Number',
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: .5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: .5,
                                            ),

                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: .5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: .5,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                  color: Colors.grey,
                                                  width: .5,
                                                ),
                                              ),
                                          hintStyle: Styles.textStyleMedium(
                                            context,
                                          ),
                                        ),
                                        style: Styles.textStyleMedium(context),
                                      ),
                                    ),
                                    if (isLoading)
                                      const Positioned(
                                        right: 20,
                                        child: SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                  ],
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
                                  : "Send otp".toUpperCase(),
                          textcolor: AppColor.whiteColor,
                          textsize: 20 * (width / 375),
                          fontWeight: FontWeight.w600,
                          letterspacing: 0.7,
                          buttoncolor: AppColor.maincolor,

                          buttonheight: 52 * (height / 812),
                          buttonwidth: width,
                          radius: 20,
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              FocusScope.of(context).unfocus();

                              try {
                                await AppDialogue.openLoadingDialogAfterClose(
                                  context,
                                  text: "Sending...",
                                  load:
                                      () async => await loginProvider.sendOTP(
                                        mobile: mobile.text,
                                      ),
                                  afterComplete: (resp) async {
                                    if (!context.mounted) return;
                                    if (resp.status) {
                                      await SecureStorageService.write(
                                        AppConstants.userMobile,
                                        mobile.text,
                                      );
                                      AppDialogue.toast(
                                        resp.data ??
                                            resp.fullBody['message'] ??
                                            "OTP sent successfully",
                                      );

                                      if (!context.mounted) return;
                                      AppRouteName.otp.push(context);
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
          ),
        ],
      ),
    );
  }
}
