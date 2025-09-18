import 'package:flutter/material.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';
import 'package:my_food_my_price/widgets/drawer_list_tile.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String versionName = '';
  String versionCode = '';

  @override
  void initState() {
    super.initState();
    getAppversion();
  }

  getAppversion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      versionName = packageInfo.version;
      versionCode = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:const CommonAppBar(title: "About", showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              DrawerListTile(
                title: "Privacy Policy",
                onTap: () {
                  AppRouteName.privacyPolicy.push(context);
                },
              ),
              const SizedBox(height: 20),
              DrawerListTile(
                title: "Terms & Conditions",
                onTap: () {
                  // AppRouteName.myOrdersPage.push(context);
                },
              ),
              const SizedBox(height: 20),
              DrawerListTile(
                title: "Cancelation & Refund Policy",
                onTap: () {
                  AppRouteName.refundPOlicy.push(context);
                },
              ),
              const SizedBox(height: 20),
              DrawerListTile(
                title: "Shipping & Delivery Policy",
                onTap: () {
                   AppRouteName.shippingPolicy.push(context);
                },
              ),
              const SizedBox(height: 20),
              DrawerListTile(
                title: "Contact Us",
                onTap: () {
                  AppRouteName.contactUs.push(context);
                },
              ),
              const SizedBox(height: 20),
              appVersion(
                title: "App version",
                subtitle: "$versionName + $versionCode Live",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appVersion({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Styles.textStyleMedium(context, color: Colors.black),
            textScaler: TextScaler.linear(1.0),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Styles.textSmall(
              context,
              color: AppColor.maincolor,
            ).copyWith(fontWeight: FontWeight.bold, fontSize: 15),
            textScaler: TextScaler.linear(1.0),
          ),
        ],
      ),
    );
  }
}
