import 'package:flutter/material.dart';

import '../../../core/app_color.dart';
import '../../model/seeker_profile.dart';

/// One cell of the category grid: a line icon above its label, in an outlined
/// card that turns blue when picked.
class InterestTile extends StatelessWidget {
  const InterestTile({
    super.key,
    required this.interest,
    required this.selected,
    required this.onTap,
  });

  final ServiceInterest interest;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColor.authAccent.withValues(alpha: 0.06)
                : AppColor.authSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColor.authAccent : AppColor.authFieldBorder,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                interest.icon,
                size: 22,
                color: selected
                    ? AppColor.authAccent
                    : AppColor.authTextSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                interest.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? AppColor.authAccent
                      : AppColor.authTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
