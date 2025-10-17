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

class FixedPricePaymentPage extends StatefulWidget {
  final List<RestaurantMenuModel> menus;
  final String pickupDate;
  final String pickupPoint;
  final Restaurant restaurant;
  final bool fromFlashPage;

  const FixedPricePaymentPage({
    super.key,
    required this.menus,
    required this.pickupDate,
    required this.pickupPoint,
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
  late String selectedPickupPoint;
  late bool fromFlashPage;

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
    quantities = List.filled(widget.menus.length, 1);
    selectedPickupDate = widget.pickupDate;
    selectedPickupPoint = widget.pickupPoint;
    fromFlashPage = widget.fromFlashPage;
    Future.microtask(() async {
      await orderProvider.getPickupTime(
        franchiseId: widget.restaurant.franchiseId,
        pickupDate: widget.pickupDate,
      );
    });
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
                  menus: widget.menus,
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
                  menus: widget.menus,
                  quantities: quantities,
                  onPriceUpdate: (data) => setState(() => priceData = data),
                  fromFlashPage: fromFlashPage,
                ),
                SizedBox(height: size.height * 0.02),

                /// 📍 Pickup Details
                PickupDetailsSection(
                  pickupDate: widget.pickupDate,
                  pickupPoint: widget.pickupPoint,
                  franchiseId: widget.restaurant.franchiseId,
                  restaurant: widget.restaurant,
                  isFixedOrder: true,
                  onDateChange:
                      (newDate) => setState(() => selectedPickupDate = newDate),
                  onPickupPointChange:
                      (newPoint) =>
                          setState(() => selectedPickupPoint = newPoint),
                            fromFlashPage: fromFlashPage,
                ),
                SizedBox(height: size.height * 0.02),

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

    for (int i = 0; i < widget.menus.length; i++) {
      if (quantities[i] > 0) {
        validItems.add(widget.menus[i]);
        validQuantities.add(quantities[i]);
      }
    }

    if (validItems.isEmpty) {
      AppDialogue.toast(
        "Please select at least one menu item before proceeding",
      );
      return;
    }
    final pickupTime = orderProvider.selectedPickupTime?.time;
    if (pickupTime == null || pickupTime.isEmpty) {
      Dialogs.snackbar("Please select pickup time", context, isError: true);
      return;
    }
    final apiPickupDate = _formatDateForApi(selectedPickupDate);
    debugPrint("📅 Formatted pickup date for API: $apiPickupDate");

    final transactionId = "MT${DateTime.now().millisecondsSinceEpoch}";
    final payable = data.payable;
    final gst = data.gst;
    final walletUsed = data.walletUsed;

    try {
      await AppDialogue.openLoadingDialogAfterClose(
        context,
        text: "Placing your order...",
        load: () async {
          return await orderProvider.placeFixedOrder(
            franchiseId: widget.restaurant.franchiseId,
            userId: profile.id.toString(),
            menuIds: widget.menus.map((m) => m.id.toString()).toList(),
            menuNames: widget.menus.map((m) => m.menuName).toList(),
            menuQuantities: quantities.map((q) => q.toString()).toList(),
            totalMenuPrices:
                widget.menus.asMap().entries.map((e) {
                  final menu = e.value;
                  final qty = quantities[e.key];
                  final total =
                      menu.getDisplayPrice(fromFlashPage: fromFlashPage) * qty;
                  return total.toStringAsFixed(2);
                }).toList(),
            name: profile.name,
            pickupPoint: selectedPickupPoint,
            pickupTime: pickupTime,
            mobile: profile.mobile,
            transactionAmount: payable.toStringAsFixed(2),
            merchantTransactionId: transactionId,
            wallet: walletUsed.toStringAsFixed(2),
            gst: gst.toStringAsFixed(2),
            pickupDate: apiPickupDate,
            contactCustomer: restaurantContact ? 1 : 0,
          );
        },
        afterComplete: (result) async {
          if (!context.mounted) return;

          if (result is Map<String, dynamic> &&
              result['status'] == 'stock_error') {
            final data = result['data'];
            final menuId = data['menu_id'];
            final available = data['avaliable_stock'];
            final msg = result['message'] ?? "Stock issue";

            // 🔹 find affected menu
            final index = widget.menus.indexWhere(
              (m) => m.id.toString() == menuId.toString(),
            );
            if (index != -1) {
              setState(() {
                widget.menus[index] = widget.menus[index].copyWith(
                  avaliableStocks: available,
                );
                quantities[index] = available;
              });
            }

            Dialogs.snackbar(msg, context, isError: true);
            return; // stop flow, let user review again
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
                    );
                  } else {
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
  ) async {
    await AppDialogue.openLoadingDialogAfterClose(
      context,
      text: "Verifying payment...",
      load:
          () async => await orderProvider.fetchPaymentStatus(
            merchantTransactionId: txnId,
          ),
      afterComplete: (status) async {
        final result = status?.toString().toLowerCase() ?? "failed";
        if (result == "success") {
          if (walletUsed > 0) {
            await orderProvider.verifyAndUpdateWallet(
              merchantTransactionId: txnId,
              walletUsed: walletUsed.toStringAsFixed(2),
            );
          }
          if (!context.mounted) return;
          await AppRouteName.fixedPricePaymentSuccessPage.pushAndRemoveUntil(
            context,
            (_) => false,
          );
        } else {
          if (!context.mounted) return;
          await AppRouteName.fixedPricePaymentFailedPage.push(context);
        }
      },
    );
  }
}
