import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/ratings_provider.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/app_shimmer.dart';
import '../../widgets/dilogue/dilogue.dart';
import '../../widgets/shimmer_type.dart';
import 'Widgets/feedback_section.dart';
import 'Widgets/franchise_header_section.dart';
import 'Widgets/menu_ratings_section.dart';
import 'Widgets/other_feedback_section.dart';
import 'Widgets/user_header_section.dart';

class RatingsPage extends StatefulWidget {
  final String franchiseName;
  final List<String> menuCategoryNames;
  final List<String> menuCategoryIds;
  final List<String> orderIds;
  final String location;
  final String franchiseImage;
  final String franchiseId;
  final String orderType;

  const RatingsPage({
    super.key,
    required this.franchiseName,
    required this.menuCategoryNames,
    required this.menuCategoryIds,
    required this.orderIds,
    required this.location,
    required this.franchiseImage,
    required this.franchiseId,
    required this.orderType,
  });

  @override
  State<RatingsPage> createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<RatingsProvider>().getFeedback(
        franchiseId: widget.franchiseId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = context.watch<RatingsProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "Customer Feedback", showBack: true),
      body:
          provider.isLoading
              ? const Center(child: AppShimmer(type: ShimmerType.menu))
              : SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.02),
                      UserHeaderSection(),
                      Divider(height: size.height * 0.02),
                      FranchiseHeaderSection(
                        franchiseName: widget.franchiseName,
                        location: widget.location,
                        franchiseImage: widget.franchiseImage,
                        avgRating: provider.averageRating,
                        menuCategoryNames: widget.menuCategoryNames,
                      ),
                      const Divider(),
                      MenuRatingsSection(
                        menuNames: widget.menuCategoryNames,
                        menuCategoryIds: widget.menuCategoryIds,
                        provider: provider,
                      ),
                      const SizedBox(height: 20),
                      FeedbackSection(
                        controller: _feedbackController,
                        provider: provider,
                        onSubmit: () async {
                          if (!context.mounted) return;
                          await AppDialogue.openLoadingDialogAfterClose(
                            context,
                            text: "Submitting feedback...",
                            load: () async {
                              return await provider.submitRatings(
                                context: context,
                                orderIds: widget.orderIds,
                                menuCategoryIds: widget.menuCategoryIds,
                                franchiseId: widget.franchiseId,
                                feedback: _feedbackController.text,
                              );
                            },
                            afterComplete: (success) async {
                              if (!context.mounted) return;
                              if (success == true) {
                                AppDialogue.toast(
                                  "Thank you for your feedback!",
                                );
                                Navigator.pop(context, true);
                              } else {
                                AppDialogue.toast(
                                  "Failed to submit feedback. Try again.",
                                );
                              }
                            },
                          );
                        },
                      ),

                      const Divider(),
                      OtherFeedbackSection(ratings: provider.ratings),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
    );
  }
}
