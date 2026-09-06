import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// The small capsule that marks an area, a provider or a requirement's
/// state: a green LIVE/OPEN with a dot, a green ACCEPTED without one, or a
/// flat grey COMING SOON.
class StatusPill extends StatelessWidget {
  const StatusPill.live({super.key, this.label = 'LIVE'})
    : _isLive = true,
      _hasDot = true;

  const StatusPill.open({super.key, this.label = 'OPEN'})
    : _isLive = true,
      _hasDot = true;

  /// A requirement somebody has already been given.
  ///
  /// Green like OPEN, because it is also a good outcome, but without the
  /// pulse dot — the dot means "live, still taking offers", which this is
  /// not. The posts board draws it exactly this way.
  const StatusPill.accepted({super.key, this.label = 'ACCEPTED'})
    : _isLive = true,
      _hasDot = false;

  const StatusPill.comingSoon({super.key, this.label = 'COMING SOON'})
    : _isLive = false,
      _hasDot = false;

  final String label;
  final bool _isLive;
  final bool _hasDot;

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
          if (_hasDot) ...[
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
