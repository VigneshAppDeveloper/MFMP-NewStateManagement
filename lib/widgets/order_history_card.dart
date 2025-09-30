import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/OrderModels/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Header row (status + rating)
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    order.status,
                    style: Styles.textSmall(context, color: Colors.green),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  "Your Ratings ⭐ ${order.rating}",
                  style: Styles.textExtraSmall(context, color: Colors.red),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),

          // ✅ Restaurant details
          Text(
            order.restaurantName,
            style: Styles.textSmall(context),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(height: size.height * 0.005),

          Row(
            children: [
              Flexible(
                child: Text(
                  order.ownerName,
                  style: Styles.textSmall(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.phone, size: 16, color: Colors.black),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  order.ownerPhone,
                  style: Styles.textSmall(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          Divider(height: size.height * 0.03),

          // ✅ Pickup details
          Row(
            children: [
              const Icon(Icons.place, color: Colors.red, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${order.pickupPoint} ⭐ ${order.rating}",
                  style: Styles.textSmall(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  const url =
                      "https://www.google.com/maps/dir/Thanjavur/Thanjavur,+Tamil+Nadu/@10.7877081,79.0560269,12z/data=!3m1!4b1!4m14!4m13!1m5!1m1!1s0x3baab89cea453039:0xe113da9b1f632be6!2m2!1d79.1384288!2d10.787719!1m5!1m1!1s0x3baab89cea453039:0xe113da9b1f632be6!2m2!1d79.1384288!2d10.787719!3e9?entry=ttu&g_ep=EgoyMDI1MDkyMS4wIKXMDSoASAFQAw%3D%3D";

                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    throw "Could not launch $url";
                  }
                },
                icon: const Icon(Icons.map, size: 18),
                label: const Text("Map Location"),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),

          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  order.pickupDate,
                  style: Styles.textSmall(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  order.pickupTime,
                  style: Styles.textSmall(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.005),
          Text(
            "Booking Details : ${order.bookingDate} | ${order.bookingTime}",
            style: Styles.textExtraSmall(context, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),

          Divider(height: size.height * 0.03),

          // ✅ Item Details
          Text(
            order.itemDetails,
            style: Styles.textSmall(context),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: size.height * 0.01),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Bill Total", style: Styles.textSmall(context)),
              Flexible(
                child: Text(
                  "₹ ${order.total.toStringAsFixed(2)}",
                  style: Styles.textSmall(context, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          Divider(height: size.height * 0.03),

          // ✅ Actions
          GestureDetector(
            onTap: () {},
            child: Text(
              "❌ Cancel Order",
              style: Styles.textSmall(context, color: Colors.red),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: size.height * 0.01),

          Text(
            "For issues call: 📞 ${order.ownerPhone}",
            style: Styles.textExtraSmall(context, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
