import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Providers/restaurant_provider.dart';
import '../../models/policy_model.dart';
import '../../util/color_constant.dart';
import '../../util/url_launcher.dart';

class TermsCondition extends StatefulWidget {
  const TermsCondition({super.key});

  @override
  State<TermsCondition> createState() => _TermsConditionState();
}

class _TermsConditionState extends State<TermsCondition> {
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
    final terms = provider.policies.firstWhere(
      (p) => p.fileType == "terms_and_condition",
      orElse: () => PolicyModel(id: 0, file: '', fileType: ''),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "Terms & Conditions", showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child:
              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  )
                  : terms.file.isEmpty
                  ? const Center(child: Text("No Terms & Conditions Found"))
                  : FutureBuilder<String>(
                    future: _loadPolicyFile(terms.file),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text("Failed to load Terms & Conditions"),
                        );
                      }
                      return Scrollbar(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: _buildClickableText(snapshot.data!, context),

                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }


  Widget _buildClickableText(String text, BuildContext context) {
  final urlRegex = RegExp(
    r'(https?:\/\/[^\s]+)',
    caseSensitive: false,
  );

  final spans = <TextSpan>[];
  final matches = urlRegex.allMatches(text);

  int lastIndex = 0;

  for (final match in matches) {
    // Add normal text before URL
    if (match.start > lastIndex) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex, match.start),
          style: Styles.textSmall(context),
        ),
      );
    }

    final url = text.substring(match.start, match.end);

    // Add clickable URL
    spans.add(
      TextSpan(
        text: url,
        style: Styles.textSmall(
          context,
          color: Colors.blue,
        ).copyWith(
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final uri = Uri.tryParse(url);
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
      ),
    );

    lastIndex = match.end;
  }

  // Add last remaining normal text
  if (lastIndex < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(lastIndex),
        style: Styles.textSmall(context),
      ),
    );
  }

  return RichText(
    text: TextSpan(children: spans),
    textScaler: const TextScaler.linear(1.0),
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
      return "Error loading Terms & Conditions";
    }
  }
}
