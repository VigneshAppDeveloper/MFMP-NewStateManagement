import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_food_my_price/Gateway/phonepay.dart';
import 'package:my_food_my_price/Providers/fixed_order_provider.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/dilogs.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/dilogue/dilogue.dart';

import '../../models/FoodModels/resturant_menu_model.dart';
import '../../models/Resturant Model/resturant.dart';
import '../../widgets/app_bar.dart';

import 'package:provider/provider.dart';

import 'Widgets/fixed_menu_list.dart';
import '../BiddinPayment/Widgets/pickup_deatils.dart';
import '../BiddinPayment/Widgets/price_summary.dart';
import '../BiddinPayment/Widgets/price_summary_data.dart';
import 'Widgets/mesage_to_resturant.dart';

class FixedPricePaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> menus;
  final String pickupDate;
  final Restaurant restaurant;
  final bool fromFlashPage;

  const FixedPricePaymentPage({
    super.key,
    required this.menus,
    required this.pickupDate,
    required this.restaurant,
    this.fromFlashPage = false,
  });

  @override
  State<FixedPricePaymentPage> createState() => _FixedPricePaymentPageState();
}

class _FixedPricePaymentPageState extends State<FixedPricePaymentPage> {
  late final FixedOrderProvider orderProvider;
  late final profile;
  late List<int> quantities;
  PriceSummaryData? priceData;
  bool restaurantContact = false;
  late String selectedPickupDate;
  //late String selectedPickupPointId;
  late bool fromFlashPage;
  late List<RestaurantMenuModel> selectedMenus;
  final TextEditingController messageController = TextEditingController();

  String _formatDateForApi(String date) {
    try {
      // handles both dd-MM-yyyy and yyyy-MM-dd
      if (date.contains('-')) {
        final parts = date.split('-');
        // if first part is 4 digits => already yyyy-MM-dd
        if (parts.first.length == 4) return date;
        // else convert dd-MM-yyyy → yyyy-MM-dd
        final d = DateFormat('dd-MM-yyyy').parse(date);
        return DateFormat('yyyy-MM-dd').format(d);
      }
      return date;
    } catch (_) {
      return date;
    }
  }

  @override
  void initState() {
    super.initState();
    orderProvider = context.read<FixedOrderProvider>();
    profile = AppConstants.profile!;
    selectedMenus =
        widget.menus.map((m) => m['menu'] as RestaurantMenuModel).toList();
    quantities = widget.menus.map((m) => m['qty'] as int).toList();
    selectedPickupDate = widget.pickupDate;
    //selectedPickupPointId = widget.pickupPoint;
    fromFlashPage = widget.fromFlashPage;
    if (!widget.fromFlashPage) {
      Future.microtask(() async {
        await orderProvider.getPickupTime(
          franchiseId: widget.restaurant.franchiseId,
          pickupDate: widget.pickupDate,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "Order Details", showBack: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// 🍱 Menu list for fixed items
                FixedMenuList(
                  menus: selectedMenus,
                  quantities: quantities,
                  onQuantityChange: (updated) {
                    setState(() => quantities = List.from(updated));
                  },
                  fromFlashPage: fromFlashPage,
                ),
                SizedBox(height: size.height * 0.02),

                /// 💰 Price Summary Section (same widget reused)
                PriceSummarySection(
                  profile: profile,
                  menus: selectedMenus,
                  quantities: quantities,
                  onPriceUpdate: (data) => setState(() => priceData = data),
                  fromFlashPage: fromFlashPage,
                ),
                SizedBox(height: size.height * 0.02),

                MessageToRestaurant(controller: messageController),
                SizedBox(height: size.height * 0.02),

                /// 📍 Pickup Details
                PickupDetailsSection(
                  pickupDate: widget.pickupDate,
                  franchiseId: widget.restaurant.franchiseId,
                  restaurant: widget.restaurant,
                  isFixedOrder: true,
                  onDateChange:
                      (newDate) => setState(() => selectedPickupDate = newDate),
                  fromFlashPage: fromFlashPage,
                ),
                SizedBox(height: size.height * 0.02),
                if (!widget.fromFlashPage) ...[
                  Row(
                    children: [
                      Checkbox(
                        value: restaurantContact,
                        onChanged: (val) {
                          setState(() => restaurantContact = val ?? false);
                        },
                        activeColor: Colors.green,
                      ),
                      Expanded(
                        child: Text(
                          "Restaurant should contact me for delivery options.",
                          style: Styles.textStyleMedium(context),
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.fromFlashPage) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.012,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFCB9D6E,
                      ).withOpacity(0.2), // #FFCB9D6E look
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "* No cancellations allowed on Flash Sale orders",
                        style: Styles.textStyleMedium(context).copyWith(
                          color: Colors.brown.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final data = priceData;
          final payable = data?.payable ?? 0.0;
          return SizedBox(
            width: size.width * 0.9,
            height: size.height * 0.07,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              label: Text(
                "Pay ₹${payable.toStringAsFixed(2)}",
                style: Styles.textStyleMediumBold(context, color: Colors.white),
                textScaler: const TextScaler.linear(1.0),
              ),
              onPressed: () async => _handlePlaceOrder(context, data),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handlePlaceOrder(
    BuildContext context,
    PriceSummaryData? data,
  ) async {
    if (data == null) {
      AppDialogue.toast("Calculating totals...");
      return;
    }

    // 🔹 Validate at least one quantity > 0
    final validItems = <RestaurantMenuModel>[];
    final validQuantities = <int>[];

    for (int i = 0; i < selectedMenus.length; i++) {
      if (quantities[i] > 0) {
        validItems.add(selectedMenus[i]);
        validQuantities.add(quantities[i]);
      }
    }

    if (validItems.isEmpty) {
      AppDialogue.toast(
        "Please select at least one menu item before proceeding",
      );
      return;
    }
    String pickupTime = "";
    if (!fromFlashPage) {
      final sel = orderProvider.selectedPickupTime?.time;
      if (sel == null || sel.isEmpty) {
        Dialogs.snackbar("Please select pickup time", context, isError: true);
        return;
      }
      pickupTime = sel;
    }
    final apiPickupDate = _formatDateForApi(selectedPickupDate);
    debugPrint("📅 Formatted pickup date for API: $apiPickupDate");
    // final selectedPickupId =
    //     context.read<MenuProvider>().selectedPickupPoint?.pickupId.toString() ??
    //     "";

    final transactionId = "MT${DateTime.now().millisecondsSinceEpoch}";
    final payable = data.payable;
    final gst = data.gst;
    final walletUsed = data.walletUsed;
    final remainingWalletAmount = data.remainingWallet;

    try {
      await AppDialogue.openLoadingDialogAfterClose(
        context,
        text: "Placing your order...",
        load: () async {
          return await orderProvider.placeFixedOrder(
            franchiseId: widget.restaurant.franchiseId,
            userId: profile.id.toString(),
            menuIds: validItems.map((m) => m.id.toString()).toList(),
            menuNames: validItems.map((m) => m.menuName).toList(),
            menuQuantities: validQuantities.map((q) => q.toString()).toList(),
            totalMenuPrices:
                validItems.asMap().entries.map((e) {
                  final menu = e.value;
                  final qty = quantities[e.key];
                  final total =
                      menu.getDisplayPrice(fromFlashPage: fromFlashPage) * qty;
                  return total.toStringAsFixed(2);
                }).toList(),
            name: profile.name,
            // pickupPoint: selectedPickupId,
            pickupTime: pickupTime,
            mobile: profile.mobile,
            transactionAmount: payable.toStringAsFixed(2),
            merchantTransactionId: transactionId,
            wallet: walletUsed.toStringAsFixed(2),
            gst: gst.toStringAsFixed(2),
            pickupDate: apiPickupDate,
            contactCustomer: restaurantContact ? 1 : 0,
            isFlash: fromFlashPage ? 1 : 0,
            message: messageController.text.trim().isNotEmpty
      ? messageController.text.trim()
      : null, // ✅ added line
          );
        },
        afterComplete: (result) async {
          if (!context.mounted) return;

          if (result is Map<String, dynamic> &&
              result['status'] == 'stock_error') {
            final data = result['data'] ?? {};
            final menuId = data['menu_id'];

            // 🔹 Detect correct stock key from backend
            final available =
                fromFlashPage
                    ? (data['flash_stock'] ?? data['avaliable_stock'] ?? 0)
                    : (data['avaliable_stock'] ?? data['flash_stock'] ?? 0);

            final msg = result['message'] ?? "Stock issue";

            // 🔹 Find which menu item failed
            final index = selectedMenus.indexWhere(
              (m) => m.id.toString() == menuId.toString(),
            );

            if (index != -1) {
              setState(() {
                // ✅ Update the correct stock field
                if (fromFlashPage) {
                  selectedMenus[index] = selectedMenus[index].copyWith(
                    flashStock: int.tryParse(available.toString()) ?? 0,
                  );
                } else {
                  selectedMenus[index] = selectedMenus[index].copyWith(
                    avaliableStocks: int.tryParse(available.toString()) ?? 0,
                  );
                }

                // ✅ Cap quantity to the new available value
                final newLimit = int.tryParse(available.toString()) ?? 0;
                quantities[index] =
                    newLimit < quantities[index] ? newLimit : quantities[index];
              });
            }

            Dialogs.snackbar(msg, context, isError: true);
            return; // stop the flow
          }

          if (result['status'] == 'success') {
            // continue payment flow
            if (payable > 0) {
              await AppDialogue.openLoadingDialogAfterClose(
                context,
                text: "Redirecting to PhonePe...",
                load: () async {
                  return await PhonePeGateway.startPayment(
                    amount: payable,
                    transactionId: transactionId,
                    userId: profile.id.toString(),
                  );
                },
                afterComplete: (payment) async {
                  final status =
                      (payment?["status"] ?? "").toString().toLowerCase();
                  if (status == "success" || status == "completed") {
                    await _verifyPaymentStatus(
                      context,
                      transactionId,
                      walletUsed,
                      remainingWalletAmount,
                    );
                  } else {
                    debugPrint("❌ Payment failed or cancelled");
                    await AppRouteName.fixedPricePaymentFailedPage.push(
                      context,
                    );
                  }
                },
              );
            }
          } else {
            AppDialogue.toast(result['message'] ?? "Order failed");
          }
        },
      );
    } catch (e) {
      AppDialogue.toast("Error: $e");
    }
  }

 Future<void> _verifyPaymentStatus(
  BuildContext context,
  String txnId,
  double walletUsed,
  double remainingWalletAmount,
) async {
  await AppDialogue.openLoadingDialogAfterClose(
    context,
    text: "Verifying payment...",
    load: () async {
      return await orderProvider.fetchPaymentStatus(
        merchantTransactionId: txnId,
      );
    },
    afterComplete: (status) async {
      final result = status?.toString().toLowerCase() ?? "failed";

      if (result == "success") {
        // ✅ Step 1: update wallet + profile if wallet was used
        if (walletUsed > 0) {
          await AppDialogue.openLoadingDialogAfterClose(
            context,
            text: "Updating wallet & refreshing profile...",
            load: () async {
              await orderProvider.verifyAndUpdateWallet(
                merchantTransactionId: txnId,
                remainingWalletAmount: remainingWalletAmount.toStringAsFixed(2),
                context: context,
              );
              return true;
            },
            afterComplete: (_) async {
              debugPrint("✅ Wallet updated and profile refreshed");
            },
          );
        }

        // ✅ Step 2: go to success page
        if (!context.mounted) return;
        await AppRouteName.fixedPricePaymentSuccessPage.pushAndRemoveUntil(
          context,
          (_) => false,
          args: {"fromFlashPage": fromFlashPage},
        );
      } else {
        // ❌ Payment failed
        if (!context.mounted) return;
        await AppRouteName.fixedPricePaymentFailedPage.push(context);
      }
    },
  );
}

}
