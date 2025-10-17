import 'package:flutter/material.dart';

import '../../../util/app_contant.dart';
import '../../../util/styles.dart';

class UserHeaderSection extends StatelessWidget {
  const UserHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = AppConstants.profile;

    final name = profile?.name ?? 'User';
    final image = (profile?.imageUrl.isNotEmpty ?? false)
        ? profile!.imageUrl
        : AppConstants.networkImage;

    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey[300],
          backgroundImage: NetworkImage(image),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Styles.textStyleMediumBold(context),
              textScaler: const TextScaler.linear(1.0),
            ),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  "Order Success",
                  style: Styles.textSmall(context, color: Colors.green),
                  textScaler: const TextScaler.linear(1.0),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}