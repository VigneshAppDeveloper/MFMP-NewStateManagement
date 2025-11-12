import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';
import 'package:my_food_my_price/widgets/dilogue/dilogue.dart';
import 'package:share_plus/share_plus.dart';

class Rewards extends StatefulWidget {
  const Rewards({super.key});

  @override
  State<Rewards> createState() => _RewardsState();
}

class _RewardsState extends State<Rewards> {
  final wallet = AppConstants.profile?.wallet ?? '0';
  final referralCode = AppConstants.profile?.referralCode ?? 'N/A';
  final referralCash = "₹25.00";
  final couponCode = "COUPON25";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "Rewards", showBack: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // _buildTotalCashCard(context, size),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 18,
                              offset: const Offset(10, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Column(
                            children: [
                              titleRow(context),
                              const SizedBox(height: 30),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/coin.png',
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height:
                                        MediaQuery.of(context).size.width * 0.1,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      wallet,
                                      style: Styles.textStyleLarge(
                                        context,
                                        color: Colors.black,
                                      ).copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 24,
                                      ),
                                      textScaler: const TextScaler.linear(1.0),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              // const SizedBox(height: 30),
                              // _buildCashTile(
                              //   context,
                              //   icon: Icons.account_balance_wallet,
                              //   label: "Deposit cash",
                              //   value: wallet,
                              //   buttonLabel: "Add Cash",
                              //   onPressed: () {},
                              //   showAddIcon: true,
                              // ),

                              const SizedBox(height: 30),
                              _buildCashTile(
                                context,
                                icon: Icons.monetization_on_outlined,
                                label: "Referral Cash",
                                value: wallet,
                                buttonLabel: referralCode,
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: referralCode),
                                  );
                                  AppDialogue.toast("Coupon code copied!");
                                },
                                isCopy: true,
                              ),
                              // const SizedBox(height: 30),
                              // _buildCashTile(
                              //   context,
                              //   icon: Icons.card_giftcard,
                              //   label: "Coupon Reward",
                              //   value: "₹10",
                              //   buttonLabel: referralCode,
                              //   onPressed: () {},
                              //   isCopy: false,
                              // ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 🆕 Referral Info Row with Share Button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 18,
                              offset: const Offset(10, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 📛 Referral Icon
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColor.maincolor.withAlpha(25),
                              child: const Icon(
                                Icons.emoji_people_outlined,
                                color: AppColor.maincolor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // 🧾 Referral Message
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "MyFood MyPrice",
                                    style: Styles.textStyleMedium(context),
                                    textScaler: const TextScaler.linear(1.0),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Referral rewards up to ₹25!",
                                    style: Styles.textSmall(
                                      context,
                                      color: Colors.black54,
                                    ),
                                    textScaler: const TextScaler.linear(1.0),
                                  ),
                                ],
                              ),
                            ),

                            // 🔗 Share Button
                            InkWell(
                              onTap: _onSharePressed,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.maincolor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.share,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Share",
                                      style: Styles.textSmall(
                                        context,
                                        color: Colors.white,
                                      ),
                                      textScaler: const TextScaler.linear(1.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget titleRow(BuildContext context) {
    return Row(
      children: [
        Text(
          "Total Cash",
          style: Styles.textStyleLarge(context),
          textScaler: const TextScaler.linear(1.0),
        ),
        // const SizedBox(width: 6),
        // const Icon(Icons.info_outline, size: 18, color: Colors.grey),

        // const Spacer(),
        // Text(
        //   "Transaction History",
        //   style: Styles.textSmall(context, color: Colors.grey),
        //   textScaler: const TextScaler.linear(1.0),
        // ),
      ],
    );
  }

  Widget _buildCashTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? buttonLabel,
    VoidCallback? onPressed,
    bool isCopy = false,
    bool showAddIcon = false, // ✅ NEW PARAM
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColor.maincolor.withAlpha(25),
          child: Icon(icon, color: AppColor.maincolor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Styles.textStyleMedium(context),
                textScaler: const TextScaler.linear(1.0),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Styles.textStyleMedium(context, color: Colors.green),
                textScaler: const TextScaler.linear(1.0),
              ),
            ],
          ),
        ),
        if (buttonLabel != null)
          InkWell(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCopy ? AppColor.maincolor : AppColor.maincolor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (showAddIcon) // ✅ Only show for Add Cash button
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  Text(
                    buttonLabel,
                    style: Styles.textSmall(context, color: Colors.white),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  if (isCopy)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.copy, size: 16, color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _onSharePressed() async {
    //final referralCode = AppConstants.profile?.referralCode ?? 'MYCODE25';
 const String message =
        'I am using MyFoodMyPrice and getting great benefits. You can also download MyFoodMyPrice at';
    const String appLink =
        'https://play.google.com/store/apps/details?id=com.biryanipalayam.myfoodmyprice';

    final String fullText =
        '$message\n$appLink\nPlease use my referral code: $referralCode during installation.';
   

    final result = await Share.share(fullText, subject: 'Join MyFoodMyPrice');

    if (result.status == ShareResultStatus.success) {
      AppDialogue.toast("Thanks for sharing!");
    }
  }
}
