import 'package:flutter/material.dart';
import 'package:my_food_my_price/Gateway/phonepay.dart';

import '../util/styles.dart';
import 'payment_method_model.dart';

// class PaymentSelector {
//   static Future<PaymentMethod?> show(BuildContext context) async {
//     final upiApps = await PhonePeGateway.getInstalledUpiApps();

//     final List<PaymentMethod> upiMethods = upiApps.map((app) {
//       final appName = app['applicationName'] ?? 'UPI App';
//       return PaymentMethod(
//         id: app['packageName'] ?? appName,
//         name: appName,
//         icon: Icons.account_balance_wallet_outlined,
//         type: 'upi',
//       );
//     }).toList();

//     final List<PaymentMethod> otherMethods = [
//       PaymentMethod(
//         id: 'card',
//         name: 'Credit / Debit Card',
//         icon: Icons.credit_card,
//         type: 'card',
//       ),
//       PaymentMethod(
//         id: 'netbanking',
//         name: 'Net Banking',
//         icon: Icons.account_balance,
//         type: 'netbanking',
//       ),
//       PaymentMethod(
//         id: 'wallet',
//         name: 'Wallets (Paytm / Amazon)',
//         icon: Icons.account_balance_wallet,
//         type: 'wallet',
//       ),
//     ];

//     return await showModalBottomSheet<PaymentMethod>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (context) {
//         return _PaymentSheet(
//           upiMethods: upiMethods,
//           otherMethods: otherMethods,
//         );
//       },
//     );
//   }
// }

// class _PaymentSheet extends StatefulWidget {
//   final List<PaymentMethod> upiMethods;
//   final List<PaymentMethod> otherMethods;

//   const _PaymentSheet({
//     required this.upiMethods,
//     required this.otherMethods,
//   });

//   @override
//   State<_PaymentSheet> createState() => _PaymentSheetState();
// }

// class _PaymentSheetState extends State<_PaymentSheet> {
//   PaymentMethod? selected;

//   // ✅ Smart Icon Picker
//   String _getUpiIcon(String packageName) {
//     if (packageName.contains('phonepe')) {
//       return 'assets/icons/coin.png';
//     } else if (packageName.contains('paisa.user')) {
//       return 'assets/icons/coin.png';
//     } else if (packageName.contains('paytm')) {
//       return 'assets/icons/coin.png';
//     } else if (packageName.contains('amazon')) {
//       return 'assets/icons/coin.png';
//     }
//     return 'assets/icons/coin.png';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final textScale = const TextScaler.linear(1.0);

//     return Container(
//       height: size.height * 0.78,
//       padding: EdgeInsets.symmetric(
//         horizontal: size.width * 0.04,
//         vertical: size.height * 0.02,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Container(
//               height: 4,
//               width: size.width * 0.12,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade400,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//           SizedBox(height: size.height * 0.02),

//           Text(
//             "Select Payment Method",
//             style: Styles.textStyleMedium(context).copyWith(
//               fontWeight: FontWeight.w700,
//               color: Colors.black,
//             ),
//             textScaler: textScale,
//           ),
//           SizedBox(height: size.height * 0.02),

//           // 🔹 UPI Apps Section
//           if (widget.upiMethods.isNotEmpty) ...[
//             Text(
//               "UPI Apps",
//               style: Styles.textSmall(context).copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade700,
//               ),
//               textScaler: textScale,
//             ),
//             SizedBox(height: size.height * 0.012),
//             SizedBox(
//               height: size.height * 0.13,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: widget.upiMethods.length,
//                 separatorBuilder: (_, __) =>
//                     SizedBox(width: size.width * 0.04),
//                 itemBuilder: (context, index) {
//                   final method = widget.upiMethods[index];
//                   final isSelected = selected?.id == method.id;
//                   final iconPath = _getUpiIcon(method.id);

//                   return GestureDetector(
//                     onTap: () {
//                       setState(() => selected = method);
//                       Navigator.pop(context, method);
//                     },
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       width: size.width * 0.23,
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? Colors.green.shade50
//                             : Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(
//                           color: isSelected
//                               ? Colors.green
//                               : Colors.grey.shade300,
//                         ),
//                       ),
//                       padding: EdgeInsets.all(size.width * 0.025),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Image.asset(
//                             iconPath,
//                             height: size.width * 0.12,
//                             width: size.width * 0.12,
//                             fit: BoxFit.contain,
//                           ),
//                           SizedBox(height: size.height * 0.006),
//                           Text(
//                             method.name,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             textAlign: TextAlign.center,
//                             style: Styles.textSmall(context).copyWith(
//                               fontWeight: isSelected
//                                   ? FontWeight.w600
//                                   : FontWeight.w400,
//                             ),
//                             textScaler: textScale,
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: size.height * 0.025),
//           ],

//           // 🔹 Other Payment Options
//           Text(
//             "Other Options",
//             style: Styles.textSmall(context).copyWith(
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade700,
//             ),
//             textScaler: textScale,
//           ),
//           SizedBox(height: size.height * 0.012),
//           Expanded(
//             child: ListView.separated(
//               itemCount: widget.otherMethods.length,
//               separatorBuilder: (_, __) => Divider(height: 1),
//               itemBuilder: (context, index) {
//                 final method = widget.otherMethods[index];
//                 final isSelected = selected?.id == method.id;
//                 return ListTile(
//                   dense: true,
//                   minLeadingWidth: size.width * 0.1,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: size.width * 0.01,
//                     vertical: size.height * 0.004,
//                   ),
//                   onTap: () {
//                     setState(() => selected = method);
//                     Navigator.pop(context, method);
//                   },
//                   leading: Icon(
//                     method.icon,
//                     color: isSelected ? Colors.green : Colors.black54,
//                     size: size.width * 0.06,
//                   ),
//                   title: Text(
//                     method.name,
//                     style: Styles.textStyleMedium(context).copyWith(
//                       fontWeight:
//                           isSelected ? FontWeight.w600 : FontWeight.w400,
//                       color: Colors.black,
//                     ),
//                     textScaler: textScale,
//                   ),
//                   trailing: Icon(
//                     Icons.arrow_forward_ios,
//                     size: size.width * 0.04,
//                     color: Colors.grey.shade600,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }