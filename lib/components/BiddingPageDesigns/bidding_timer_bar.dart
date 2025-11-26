import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

import '../../Providers/bidding_provider.dart';

class BiddingTimerBar extends StatelessWidget {
  const BiddingTimerBar({super.key});

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(d.inHours);
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return "$h:$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BiddingProvider>();
    final remaining = provider.remaining;
    final ended = provider.biddingEnded;
    final formatted = _format(remaining);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColor.maincolor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 4,
                blurRadius: 10,
              ),
            ],
          ),
          child: RichText(
            textScaler: const TextScaler.linear(1.0),
            text: TextSpan(
              children: [
                TextSpan(
                  text: ended ? "00:00:00" : formatted,
                  style: Styles.textStyleMediumBold(
                    context,
                    color: Colors.white,
                  ).copyWith(fontSize: 40),
                ),
                const TextSpan(
                  text: ' sec',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          ended ? "Bidding Ended" : "Time is running!!",
          style: Styles.textStyleMediumBold(context),
          textScaler: const TextScaler.linear(1.0),
        ),
        Text(
          ended ? "Fetching winners..." : "Bid Now and get the best price",
          style: Styles.textStyleMediumBold(context),
          textScaler: const TextScaler.linear(1.0),
        ),
        const SizedBox(height: 5),
        Text(
          "Top 5% Bidders will win",
          style: Styles.textStyleMediumBold(context, color: Colors.green),
          textScaler: const TextScaler.linear(1.0),
        ),
        //const SizedBox(height: 15),
      ],
    );
  }
}


