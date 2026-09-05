import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// The small capsule that marks an area or a provider's state: a green
/// LIVE/OPEN with a dot, or a flat grey COMING SOON.
class StatusPill extends StatelessWidget {
  const StatusPill.live({super.key, this.label = 'LIVE'}) : _isLive = true;

  const StatusPill.open({super.key, this.label = 'OPEN'}) : _isLive = true;

  const StatusPill.comingSoon({super.key, this.label = 'COMING SOON'})
    : _isLive = false;

  final String label;
  final bool _isLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 9, right: 10, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: _isLive
            ? AppColor.discoveryLiveTint
            : AppColor.discoveryPillMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLive) ...[
            SvgPicture.asset(DiscoveryAssets.liveDot, width: 6, height: 6),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: _isLive ? DiscoveryText.pill : DiscoveryText.pillMuted,
          ),
        ],
      ),
    );
  }
}
