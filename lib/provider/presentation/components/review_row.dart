import 'package:flutter/material.dart';

import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_avatar.dart';
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
        // Tinted from the reviewer's own name, so a column of reviews is not
        // a column of identical dark squares.
        ProviderAvatar(
          initials: review.initials,
          seed: review.author,
          size: 36,
          isVerified: false,
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
