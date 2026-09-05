import 'package:flutter/material.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/provider/model/provider_review.dart';
import 'package:local_markerplace/provider/presentation/components/star_row.dart';

/// One review: who left it, how they rated it, when, and what they said.
class ReviewRow extends StatelessWidget {
  const ReviewRow({super.key, required this.review});

  final ProviderReview review;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.8),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.discoveryAvatarTop,
                AppColor.discoveryAvatarBottom,
              ],
            ),
          ),
          child: Text(
            review.initials,
            style: DiscoveryText.avatarInitials(12.24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      review.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DiscoveryText.reviewAuthor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(review.age, style: DiscoveryText.reviewAge),
                ],
              ),
              const SizedBox(height: 6),
              StarRow(rating: review.rating.toDouble()),
              const SizedBox(height: 9),
              Text(review.body, style: DiscoveryText.reviewBody),
            ],
          ),
        ),
      ],
    );
  }
}
