import 'package:flutter/material.dart';
import 'package:local_markerplace/core/app_color.dart';

/// The strip above the bottom button explaining why the selected mode cannot
/// be booked — an instant visit with nobody free, or a mode not built yet.
///
/// It sits with the button rather than in the scroll, so the explanation is
/// next to the control it disables.
class ModeUnavailableBanner extends StatelessWidget {
  const ModeUnavailableBanner({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.event_busy_rounded,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: AppColor.indicativeBlueColor50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColor.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: AppColor.indicativeBlueColor500),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColor.neutralGreyColor800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColor.neutralGreyColor600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
