import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_food_my_price/Providers/restaurant_provider.dart';
import 'package:my_food_my_price/models/policy_model.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/util/url_launcher.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';
import 'package:provider/provider.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().getPolicy();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final isLoading = provider.isPolicyLoading;
    final privacy = provider.policies
        .firstWhere(
          (p) => p.fileType == "privacy_policy",
          orElse: () => PolicyModel(id: 0, file: '', fileType: ''),
        );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "Privacy Policy", showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: isLoading
              ? const Center(child: CircularProgressIndicator(
                color: Colors.black,
              ))
              : privacy.file.isEmpty
                  ? const Center(child: Text("No Privacy Policy Found"))
                  : FutureBuilder<String>(
                      future: _loadPolicyFile(privacy.file),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                              child: Text("Failed to load Privacy Policy"));
                        }
                        return Scrollbar(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Text(
                              snapshot.data!,
                              style: Styles.textSmall(context),
                              textScaler: const TextScaler.linear(1.0),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Future<String> _loadPolicyFile(String url) async {
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        return utf8.decode(resp.bodyBytes);
      } else {
        throw Exception("File load failed");
      }
    } catch (e) {
      debugPrint("❌ Error loading policy file: $e");
      return "Error loading Privacy Policy";
    }
  }
}
