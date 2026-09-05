import 'package:flutter/material.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_note.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/provider/model/provider_profile.dart';
import 'package:local_markerplace/provider/presentation/components/map_thumbnail.dart';
import 'package:local_markerplace/provider/presentation/components/product_card.dart';
import 'package:local_markerplace/provider/presentation/components/provider_hero.dart';
import 'package:local_markerplace/provider/presentation/components/rating_summary.dart';
import 'package:local_markerplace/provider/presentation/components/review_row.dart';
import 'package:local_markerplace/provider/presentation/components/segmented_tabs.dart';
import 'package:local_markerplace/provider/presentation/components/service_rows.dart';
import 'package:local_markerplace/provider/repository/provider_repository.dart';

/// A provider's public page — the destination every path in discovery leads
/// to.
///
/// The page is readable signed out; only connecting and messaging are gated,
/// which is what [isSignedIn] switches. The head scrolls away with the
/// content and the tab strip pins under it, so the four sections behave like
/// one page rather than four.
class ProviderProfilePage extends StatefulWidget {
  const ProviderProfilePage({
    super.key,
    required this.providerName,
    this.isSignedIn = true,
    this.initialTab = ProviderTab.services,
    this.repository = const ProviderRepository(),
    this.onTabSelected,
    this.onPost,
  });

  final String providerName;
  final bool isSignedIn;
  final ProviderTab initialTab;
  final ProviderRepository repository;
  final ValueChanged<DiscoveryTab>? onTabSelected;
  final VoidCallback? onPost;

  @override
  State<ProviderProfilePage> createState() => _ProviderProfilePageState();
}

class _ProviderProfilePageState extends State<ProviderProfilePage> {
  late ProviderTab _tab = widget.initialTab;

  late final ProviderProfile _profile = widget.repository.forName(
    widget.providerName,
  );

  void _gatedAction(String what) {
    if (widget.isSignedIn) {
      _notice('$what — coming soon.');
      return;
    }
    _notice('Sign in to $what.');
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: DiscoveryText.heroSubtitle.copyWith(color: AppColor.white),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProviderHero(
                profile: _profile,
                isSignedIn: widget.isSignedIn,
                onConnect: () => _gatedAction('connect'),
                onChat: () => _gatedAction('chat'),
                onMore: () => _notice('More options — coming soon.'),
              ),
            ),
            if (!widget.isSignedIn)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(
                    'This page is public. Sign in to connect or start a '
                    'direct message.',
                    style: DiscoveryText.publicNote,
                  ),
                ),
              ),
            if (_profile.badgeNote != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _BadgeNote(note: _profile.badgeNote!),
                ),
              ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabsHeader(
                child: ColoredBox(
                  color: AppColor.white,
                  child: ProviderSegmentedTabs(
                    current: _tab,
                    onSelect: (tab) => setState(() => _tab = tab),
                  ),
                ),
              ),
            ),
            ..._body(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: DiscoveryTabBar(
        current: DiscoveryTab.explore,
        onSelect: (tab) => widget.onTabSelected?.call(tab),
        onPost: widget.onPost,
      ),
    );
  }

  List<Widget> _body() {
    switch (_tab) {
      case ProviderTab.services:
        return _servicesBody();
      case ProviderTab.store:
        return _storeBody();
      case ProviderTab.reviews:
        return _reviewsBody();
      case ProviderTab.about:
        return _aboutBody();
    }
  }

  List<Widget> _servicesBody() {
    final services = _profile.services;
    if (services.isEmpty) {
      return [const _Note('No services listed yet — coming soon.')];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            '${services.length} '
            '${services.length == 1 ? 'service' : 'services'}',
            style: DiscoveryText.footnote,
          ),
        ),
      ),
      SliverList.separated(
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ServiceCard(
            service: services[index],
            onBook: () => _gatedAction('book ${services[index].name}'),
          ),
        ),
      ),
    ];
  }

  List<Widget> _storeBody() {
    final products = _profile.products;
    if (products.isEmpty) {
      return [const _Note('No products listed yet — coming soon.')];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Text(
                '${products.length} products',
                style: DiscoveryText.footnoteStrong,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _notice('Cart — coming soon.'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.providerChipFill,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('2 in cart', style: DiscoveryText.addChip),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 196,
          ),
          itemBuilder: (context, index) => ProductCard(
            product: products[index],
            onAdd: () => _gatedAction('add ${products[index].name}'),
          ),
        ),
      ),
    ];
  }

  List<Widget> _reviewsBody() {
    final reviews = _profile.reviews;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: RatingSummaryCard(
            rating: _profile.rating,
            reviewCount: _profile.reviewCount,
            breakdown: _profile.ratingBreakdown,
          ),
        ),
      ),
      if (reviews.isEmpty)
        const _Note('No reviews yet.')
      else
        SliverList.separated(
          itemCount: reviews.length,
          separatorBuilder: (_, _) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
          ),
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.fromLTRB(20, index == 0 ? 22 : 0, 20, 0),
            child: ReviewRow(review: reviews[index]),
          ),
        ),
    ];
  }

  List<Widget> _aboutBody() {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_profile.about, style: DiscoveryText.body),
              const SizedBox(height: 20),
              MapThumbnail(onTap: () => _notice('Map — coming soon.')),
              const SizedBox(height: 22),
              _Field(label: 'ADDRESS', value: _profile.address),
              _Field(label: 'HOURS', value: _profile.hours),
              _Field(label: 'SERVES', value: _profile.serves, isLast: true),
            ],
          ),
        ),
      ),
    ];
  }
}

/// Wraps the flow's empty-state note as a sliver.
class _Note extends StatelessWidget {
  const _Note(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: DiscoveryNote(message),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.isLast = false});

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DiscoveryText.fieldLabel),
        const SizedBox(height: 6),
        Text(value, style: DiscoveryText.fieldValue),
        if (!isLast) ...[
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColor.discoveryBorder,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _BadgeNote extends StatelessWidget {
  const _BadgeNote({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13.2),
      decoration: BoxDecoration(
        color: AppColor.providerNoteFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No verified badge', style: DiscoveryText.noteTitle),
          const SizedBox(height: 6),
          Text(note, style: DiscoveryText.noteBody),
        ],
      ),
    );
  }
}

/// Keeps the tab strip on screen once the head has scrolled past.
class _TabsHeader extends SliverPersistentHeaderDelegate {
  const _TabsHeader({required this.child});

  final Widget child;

  @override
  double get minExtent => 46;

  @override
  double get maxExtent => 46;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      child;

  @override
  bool shouldRebuild(_TabsHeader oldDelegate) => oldDelegate.child != child;
}
