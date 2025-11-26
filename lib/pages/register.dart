import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/Providers/login_provider.dart';
import 'package:my_food_my_price/Providers/register_provider.dart';
import 'package:my_food_my_price/components/button.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/services/secure_storage.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/exception.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/util/validator.dart';
import 'package:my_food_my_price/widgets/dilogue/dilogue.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? tokenFCM;
  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController referralCode = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool termsAccepted = false;
  bool privacyAccepted = false;
  bool isLoading = false;

  RegisterProvider get registerProvider => context.read<RegisterProvider>();

  @override
  void initState() {
    super.initState();
    getdata();
    getFcmToken();
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

  getFcmToken() async {
    tokenFCM = (await FirebaseMessaging.instance.getToken())!;
    if (tokenFCM != null) {
      tokenFCM = tokenFCM;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: height / 20),
                Image.asset("assets/icons/MFMP-logo-1.jpg", width: 250),
                SizedBox(height: height / 50),
                Text(
                  'SIGN UP',
                  style: Styles.textStyleExtraLarge(
                    context,
                    color: AppColor.blackColor,
                  ),
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.0),
                ),
                SizedBox(height: height / 30),
        
                buildTextField(
                  context: context,
                  controller: name,
                  hint: 'Full Name',
                  validator: Validator.notEmpty,
                  icon: Icons.person,
                ),
                buildTextField(
                  context: context,
                  controller: mobile,
                  hint: 'Mobile Number',
                  validator: Validator.notEmpty,
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  readOnly: true,
                ),
                buildTextField(
                  context: context,
                  controller: email,
                  hint: 'Email Address',
                  validator: Validator.validateEmail,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                buildTextField(
                  context: context,
                  controller: referralCode,
                  hint: 'Referral Code (optional)',
                  validator: (_) => null,
                  icon: Icons.card_giftcard,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: termsAccepted,
                      onChanged: (bool? newValue) {
                        setState(() {
                          termsAccepted = newValue ?? false;
                        });
                      },
                      activeColor: AppColor.maincolor,
                      checkColor: Colors.white,
                      splashRadius: 20,
                      visualDensity: VisualDensity.compact, // reduces size
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: Colors.grey, width: 1),
                      mouseCursor: SystemMouseCursors.click,
                      autofocus: false,
                      isError: false,
                      semanticLabel: 'Accept Terms & Conditions',
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: "I accept the ",
                          style: Styles.textSmall(
                            context,
                            color: Colors.grey.shade700,
                          ),
                          children: [
                            TextSpan(
                              text: "Terms & Conditions",
                              style: Styles.textSmall(
                                context,
                                color: AppColor.maincolor,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                              ),
                              recognizer:
                                  TapGestureRecognizer()..onTap = () {
                                    AppRouteName.termsConditions.push(context);
                                  },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: privacyAccepted,
                      onChanged: (bool? newValue) {
                        setState(() {
                          privacyAccepted = newValue ?? false;
                        });
                      },
                      activeColor: AppColor.maincolor,
                      checkColor: Colors.white,
                      splashRadius: 20,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: Colors.grey, width: 1),
                      mouseCursor: SystemMouseCursors.click,
                      autofocus: false,
                      isError: false,
                      semanticLabel: 'Agree to share required data',
                    ),
                    Expanded(
                      child: Text(
                        "I agree to share my required data for this app.",
                        style: Styles.textSmall(
                          context,
                          color: Colors.grey.shade700,
                        ),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ),
                  ],
                ),
        
                SizedBox(height: height / 30),
                MyButton(
                  text: isLoading ? 'Loading...' : "Register".toUpperCase(),
                  textcolor: AppColor.whiteColor,
                  textsize: 20 * (width / 375),
                  fontWeight: FontWeight.w600,
                  letterspacing: 0.7,
                  buttoncolor: AppColor.maincolor,
        
                  buttonheight: 52 * (height / 812),
                  buttonwidth: width,
                  radius: 15,
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    if (!termsAccepted || !privacyAccepted) {
                      AppDialogue.snackBar(
                        context,
                        content: "Please accept the agreements",
                      );
                      return;
                    }
        
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
        
                    final navigator = Navigator.of(
                      context,
                    ); // ✅ Capture before await
        
                    try {
                      await AppDialogue.openLoadingDialogAfterClose(
                        context,
                        text: "Creating Profile...",
                        load: () async {
                          return await registerProvider.createProfile(
                            name: name.text.trim(),
                            mobile: mobile.text.trim(),
                            email: email.text.trim(),
                            devieToken: tokenFCM ?? '',
                            referralCode: referralCode.text.trim(),
                            loginProvider: context.read<LoginProvider>(),
                          );
                        },
                        afterComplete: (resp) async {
                          if (!navigator.mounted) return;
        
                          if (resp.status) {
                            navigator.pushReplacementNamed(
                              AppRouteName.introPage.value,
                            );
                          } else if (registerProvider.isApiValidationError) {
                            AppDialogue.alert(
                              navigator.context,
                              title: "Validation Error",
                              content:
                                  "Please check your inputs and try again.",
                              singleButton: true,
                            );
                          } else {
                            AppDialogue.toast("Profile creation failed");
                          }
                        },
                      );
                    } catch (e) {
                      if (navigator.mounted) {
                        ExceptionHandler.showMessage(navigator.context, e);
                      }
                    }
                  },
                ),
                // Add button, etc. here
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    required IconData icon, // 👈 add this
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(1.0)),
        child: TextFormField(
          cursorColor: Colors.black,
          controller: controller,
          validator: validator,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: Styles.textSmall(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            hintText: hint,
            hintStyle: Styles.textSmall(context, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
