import 'package:flutter/material.dart';

import 'package:local_markerplace/components/art/seeded_artwork.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/core/money.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/visit/model/visit.dart';
import 'package:local_markerplace/visit/presentation/components/cart_bits.dart';
import 'package:local_markerplace/visit/presentation/components/visit_bits.dart';
import 'package:local_markerplace/visit/presentation/your_visit_page.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

/// Every cart, checked out together.
///
/// Each provider is still booked separately — they are different people
/// making different trips — but the seeker settles up once and sees one
/// total, which is what having several carts open is for.
class CheckoutAllPage extends StatefulWidget {
  const CheckoutAllPage({super.key, this.repository});

  final VisitRepository? repository;

  @override
  State<CheckoutAllPage> createState() => _CheckoutAllPageState();
}

class _CheckoutAllPageState extends State<CheckoutAllPage> {
  late final VisitRepository _visits =
      widget.repository ?? VisitRepository.shared;

  List<Visit> get _carts => _visits.carts;

  /// Opens one cart so its time can be chosen, then picks up whatever
  /// changed.
  Future<void> _open(String providerName) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            YourVisitPage(providerName: providerName, repository: _visits),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _confirmAll() async {
    final booked = _visits.confirmAll();
    if (booked.isEmpty || !mounted) return;
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => _AllBookedPage(booked: booked)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final carts = _carts;
    if (carts.isEmpty) return const SizedBox.shrink();

    final ready = carts.where((cart) => cart.isReady).toList();
    final total = ready.fold<double>(0, (sum, cart) => sum + cart.estimate);

    return Scaffold(
      backgroundColor: AppColor.discoveryTint,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DiscoveryHeader(
              title: 'Checkout',
              subtitle:
                  '${carts.length} ${carts.length == 1 ? 'cart' : 'carts'} · '
                  '${_visits.itemCount} items',
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: carts.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == carts.length) {
                    return _GrandTotal(carts: carts, ready: ready);
                  }
                  return _CartSummary(
                    cart: carts[index],
                    onChoose: () => _open(carts[index].providerName),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: AppColor.white,
          child: VisitCta(
            label: ready.isEmpty
                ? 'Choose a time to continue'
                : ready.length == carts.length
                ? 'Confirm all · ${rupees(total)}'
                : 'Confirm ${ready.length} of ${carts.length} · '
                      '${rupees(total)}',
            enabled: ready.isNotEmpty,
            onTap: _confirmAll,
          ),
        ),
      ),
    );
  }
}

/// One cart on the checkout list: who, what, when, how much.
class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart, required this.onChoose});

  final Visit cart;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final ready = cart.isReady;

    return CartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: SeededArtwork(
                  seed: cart.providerName,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cart.providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DiscoveryText.rowTitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Text(cart.contentLine, style: DiscoveryText.smallPrint),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(rupees(cart.estimate), style: DiscoveryText.chip),
            ],
          ),
          const CartDivider(top: 12, bottom: 12),
          Row(
            children: [
              Icon(
                ready ? Icons.event_available_rounded : Icons.schedule_rounded,
                size: 18,
                color: ready
                    ? AppColor.discoveryLiveText
                    : AppColor.discoveryTextTertiary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ready ? cart.whenLabel : 'No time chosen yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DiscoveryText.smallPrint.copyWith(
                    color: ready
                        ? AppColor.discoveryInkMuted
                        : AppColor.discoveryTextTertiary,
                  ),
                ),
              ),
              PressableScale(
                onTap: onChoose,
                pressedScale: 0.92,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Text(
                    ready ? 'Change' : 'Choose a time',
                    style: DiscoveryText.link.copyWith(fontSize: 12.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GrandTotal extends StatelessWidget {
  const _GrandTotal({required this.carts, required this.ready});

  final List<Visit> carts;
  final List<Visit> ready;

  @override
  Widget build(BuildContext context) {
    final waiting = carts.length - ready.length;

    return CartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final cart in carts)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      cart.providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DiscoveryText.caption,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    cart.isReady ? rupees(cart.estimate) : 'not timed',
                    style: cart.isReady
                        ? DiscoveryText.chip
                        : DiscoveryText.fine,
                  ),
                ],
              ),
            ),
          const CartDivider(top: 6, bottom: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'To confirm now',
                  style: DiscoveryText.rowTitle.copyWith(fontSize: 14),
                ),
              ),
              Text(
                rupees(
                  ready.fold<double>(0, (sum, cart) => sum + cart.estimate),
                ),
                style: DiscoveryText.visitTotal,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            waiting == 0
                ? 'Each provider is booked separately. You pay each after '
                      'their work is done.'
                : '$waiting ${waiting == 1 ? 'cart stays' : 'carts stay'} in '
                      'your list until you give them a time.',
            style: DiscoveryText.fine,
          ),
        ],
      ),
    );
  }
}

/// What was booked, once several were booked at once.
class _AllBookedPage extends StatelessWidget {
  const _AllBookedPage({required this.booked});

  final List<Visit> booked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              width: 92,
              height: 92,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.authSuccessLight,
                    AppColor.discoveryLiveText,
                  ],
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 42,
                color: AppColor.white,
              ),
            ),
            const SizedBox(height: 26),
            Text(
              booked.length == 1
                  ? 'Visit booked'
                  : '${booked.length} visits booked',
              style: DiscoveryText.providerName,
            ),
            const SizedBox(height: 8),
            Text(
              'Each provider comes separately.',
              style: DiscoveryText.heroSubtitle,
            ),
            const SizedBox(height: 26),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: booked.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final visit = booked[index];
                  return CartCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VISIT ${visit.reference ?? ''}'.trim(),
                          style: DiscoveryText.tipsHeading,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          visit.providerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DiscoveryText.rowTitle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(visit.whenLabel, style: DiscoveryText.smallPrint),
                        const SizedBox(height: 8),
                        Text(
                          '${visit.contentLine} · ${rupees(visit.estimate)}',
                          style: DiscoveryText.meta,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: VisitCta(
                label: 'Done',
                onTap: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
