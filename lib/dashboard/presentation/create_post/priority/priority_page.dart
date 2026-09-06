import 'package:flutter/material.dart';

import 'package:local_markerplace/components/motion/app_motion.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/components/primary_button.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/dashboard/model/post_priority.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/status_pill.dart';

/// 09 · 07 — how far to push a requirement.
///
/// Pops with the chosen [PostPriority], or with nothing if the seeker backs
/// out. The composer that opened it keeps the choice and does the posting;
/// no money changes hands here.
class PriorityPage extends StatefulWidget {
  const PriorityPage({
    super.key,
    required this.requirement,
    this.selected = PostPriority.standard,
    this.areaName = 'your',
  });

  /// What the seeker typed, echoed back so they know what they are boosting.
  final String requirement;

  final PostPriority selected;

  /// Named in the Standard option's description.
  final String areaName;

  @override
  State<PriorityPage> createState() => _PriorityPageState();
}

class _PriorityPageState extends State<PriorityPage> {
  late PostPriority _selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const DiscoveryHeader(title: 'How urgent is this?'),
            const SizedBox(height: 14),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.requirement.trim().isNotEmpty) ...[
                      Text(
                        widget.requirement,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: DiscoveryText.footnoteStrong.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 20 / 15,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                    for (final (index, option) in PostPriority.values.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FadeSlideIn(
                          index: index,
                          child: _PriorityOption(
                            option: option,
                            areaName: widget.areaName,
                            isSelected: option == _selected,
                            onTap: () => setState(() => _selected = option),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    const _HonestyNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _PriorityFooter(
        selected: _selected,
        onConfirm: () => Navigator.of(context).pop(_selected),
      ),
    );
  }
}

/// One of the three choices, as a card that carries its own radio.
class _PriorityOption extends StatelessWidget {
  const _PriorityOption({
    required this.option,
    required this.areaName,
    required this.isSelected,
    required this.onTap,
  });

  final PostPriority option;
  final String areaName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: AnimatedContainer(
        duration: AppMotion.quick,
        curve: AppMotion.emphasized,
        padding: const EdgeInsets.all(14.6),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColor.discoveryAccent
                : AppColor.discoveryBorder,
            width: isSelected ? 2 : 1.4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColor.discoveryAccent.withValues(alpha: 0.16),
                    blurRadius: 9,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Radio(isSelected: isSelected),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.label,
                          style: DiscoveryText.groupHeading,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        option.priceLabel,
                        // The design colours the amount by selection, not by
                        // whether it costs anything — only the chosen option
                        // is worth the accent.
                        style: DiscoveryText.offerName.copyWith(
                          color: isSelected
                              ? AppColor.discoveryGradientEnd
                              : AppColor.discoveryTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    option.description(areaName),
                    style: DiscoveryText.meta.copyWith(height: 16 / 11.5),
                  ),
                  if (option == PostPriority.priority) ...[
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: StatusPill.live(label: 'MOST CHOSEN'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? AppColor.discoveryAccent
              : AppColor.uploadDashedBorder,
          width: 2,
        ),
      ),
      child: AnimatedScale(
        scale: isSelected ? 1 : 0,
        duration: AppMotion.quick,
        curve: AppMotion.overshoot,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppColor.discoveryAccent,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// What paying does and does not buy, in the designer's own words.
class _HonestyNote extends StatelessWidget {
  const _HonestyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.discoveryTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Paying moves you up the queue and reaches more providers. It cannot '
        'guarantee someone accepts — refunded in full if nobody does.',
        style: DiscoveryText.smallPrint,
      ),
    );
  }
}

/// The running total and the way back to the composer.
class _PriorityFooter extends StatelessWidget {
  const _PriorityFooter({required this.selected, required this.onConfirm});

  final PostPriority selected;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final isPaid = selected.amount > 0;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        decoration: const BoxDecoration(
          color: AppColor.white,
          border: Border(top: BorderSide(color: AppColor.discoveryBorder)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${selected.label} boost',
                    style: DiscoveryText.caption,
                  ),
                ),
                Text(selected.priceLabel, style: DiscoveryText.chip),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    isPaid ? 'To pay now' : 'Nothing to pay',
                    style: DiscoveryText.offerName,
                  ),
                ),
                Text(
                  selected.priceLabel,
                  style: DiscoveryText.rejectedTitle.copyWith(
                    color: AppColor.discoveryInk,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              // The design posts from here. In this app the composer still
              // owns posting, so this hands the choice back rather than
              // claiming to have taken a payment.
              label: isPaid
                  ? 'Use ${selected.label} · ${selected.priceLabel}'
                  : 'Use ${selected.label}',
              enabled: true,
              gradient: true,
              height: 56,
              gradientColors: const [
                AppColor.discoveryGradientStart,
                AppColor.discoveryGradientEnd,
              ],
              labelStyle: DiscoveryText.onAccent(16.5, letterSpacing: -0.165),
              onPressed: onConfirm,
            ),
          ],
        ),
      ),
    );
  }
}
