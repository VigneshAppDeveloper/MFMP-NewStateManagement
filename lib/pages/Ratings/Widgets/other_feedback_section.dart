import 'package:flutter/material.dart';

import '../../../models/rating_model.dart';
import '../../../util/styles.dart';

class OtherFeedbackSection extends StatelessWidget {
  final List<RatingModel> ratings;

  const OtherFeedbackSection({super.key, required this.ratings});

  @override
  Widget build(BuildContext context) {
    if (ratings.isEmpty) {
      return Text(
        "No feedback available yet.",
        style: Styles.textSmall(context, color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Others Feedback", style: Styles.textStyleMediumBold(context)),
        const SizedBox(height: 10),
        ...ratings.map(
          (f) => ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  (f.userImage.isNotEmpty)
                      ? NetworkImage(f.userImage)
                      : const AssetImage('assets/icons/user.png')
                          as ImageProvider,
            ),
            title: Text(f.name, style: Styles.textStyleMediumBold(context)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < f.userRating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 16,
                    );
                  }),
                ),
                Text(f.userFeedback, style: Styles.textSmall(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
