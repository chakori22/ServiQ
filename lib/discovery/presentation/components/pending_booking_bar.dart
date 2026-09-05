import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/pending_booking.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// The blue bar above the tab bar that carries the booking the seeker has
/// left unfinished, so it is reachable from home without hunting for it.
class PendingBookingBar extends StatelessWidget {
  const PendingBookingBar({super.key, required this.booking, this.onView});

  final PendingBooking booking;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onView,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 60,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              AppColor.discoveryGradientStart,
              AppColor.discoveryGradientEnd,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.discoveryGradientEnd.withValues(alpha: 0.34),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // The soft highlight the design bleeds off the card's top-right.
            Positioned(
              right: -30,
              top: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColor.white.withValues(alpha: 0.18),
                      AppColor.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11.4),
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
                      booking.initials,
                      style: const TextStyle(
                        fontFamily: DiscoveryText.family,
                        fontSize: 12.92,
                        fontWeight: FontWeight.w800,
                        color: AppColor.discoveryAvatarText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DiscoveryText.onAccent(
                            13,
                            letterSpacing: -0.13,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${booking.providerName} · ${booking.amount}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: DiscoveryText.family,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColor.discoveryOnAccentMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'View',
                    style: DiscoveryText.onAccent(13, letterSpacing: -0.13),
                  ),
                  const SizedBox(width: 6),
                  SvgPicture.asset(
                    DiscoveryAssets.chevronOnAccent,
                    width: 5,
                    height: 11,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
