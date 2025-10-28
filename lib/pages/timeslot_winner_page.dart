import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';
import 'package:my_food_my_price/widgets/app_shimmer.dart';
import 'package:provider/provider.dart';

import '../Providers/menu_provider.dart';
import '../models/BidderModels/timeslot_winner_list.dart';
import '../util/color_constant.dart';
import '../widgets/shimmer_type.dart';
class TimeslotWinnerPage extends StatefulWidget {
  final String franchiseId;
  final String timerId;

  const TimeslotWinnerPage({
    super.key,
    required this.franchiseId,
    required this.timerId,
  });

  @override
  State<TimeslotWinnerPage> createState() => _TimeslotWinnerPageState();
}

class _TimeslotWinnerPageState extends State<TimeslotWinnerPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context
          .read<MenuProvider>()
          .getTimeSlotWinnerList(franchiseId: widget.franchiseId, timerId: widget.timerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MenuProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "Winners", showBack: true),
      body: SafeArea(
        child: provider.isWinnerLoading
            ? const AppShimmer(type:ShimmerType.menu)
            : provider.winnerList.isEmpty
                ? Center(
                    child: Text(
                     "No winners found.",
                      style: Styles.textStyleMedium(context),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.02),

                        // 🔹 Summary container
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.015,
                            horizontal: size.width * 0.05,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.maincolor,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "TOTAL BIDDERS: ${provider.totalBidderCount}",
                                style: Styles.textStyleMediumBold(
                                  context,
                                  color: Colors.white,
                                ),
                                textScaler: const TextScaler.linear(1.0),
                              ),
                              Container(
                                height: size.height * 0.025,
                                width: 1,
                                color: Colors.white54,
                              ),
                              Text(
                                "WINNERS: ${provider.winnerCount}",
                                style: Styles.textStyleMediumBold(
                                  context,
                                  color: Colors.white,
                                ),
                                textScaler: const TextScaler.linear(1.0),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 0.02),

                        // 🔹 Winner list
                        Expanded(
                          child: ListView.builder(
                            itemCount: provider.winnerList.length,
                            itemBuilder: (context, index) {
                              final winner = provider.winnerList[index];
                              return _winnerCard(context, winner, size);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _winnerCard(BuildContext context, TimeSlotWinnerListModel winner, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ExpansionTile(
            iconColor: AppColor.maincolor,
            collapsedIconColor: AppColor.maincolor,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColor.maincolor.withOpacity(0.1),
                  radius: size.width * 0.07,
                  backgroundImage: winner.menu.menuImage.isNotEmpty
                      ? NetworkImage(winner.menu.menuImage)
                      : const AssetImage("assets/icons/dummy1.png") as ImageProvider,
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        winner.user.name,
                        style: Styles.textStyleMediumBold(context),
                        textScaler: const TextScaler.linear(1.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "View Details",
                        style: Styles.textSmall(context, color: Colors.grey),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.01,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(context, "Menu", winner.menu.menuName),
                    _infoRow(
                      context,
                      "Final Price",
                      "₹${winner.finalPrice}",
                      valueColor: AppColor.maincolor,
                    ),
                    _infoRow(
                      context,
                      "Time Slot",
                      "${winner.timeslot.startingTime} - ${winner.timeslot.endTime}",
                    ),
                    _infoRow(
                      context,
                      "Date",
                      DateFormat('dd-MM-yyyy').format(DateTime.parse(winner.date)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 3,
            child: Text(
              label,
              style: Styles.textSmall(context),
              textScaler: const TextScaler.linear(1.0),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            flex: 4,
            child: Text(
              value,
              style: Styles.textSmall(
                context,
                color: valueColor ?? Colors.black87,
              ),
              textScaler: const TextScaler.linear(1.0),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}