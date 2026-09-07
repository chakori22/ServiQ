import 'package:flutter/material.dart';
import 'package:local_markerplace/basket/app_bottom_bar.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_note.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/provider/model/provider_profile.dart';
import 'package:local_markerplace/provider/model/provider_service.dart';
import 'package:local_markerplace/provider/model/store_product.dart';
import 'package:local_markerplace/provider/presentation/components/map_thumbnail.dart';
import 'package:local_markerplace/provider/presentation/components/product_card.dart';
import 'package:local_markerplace/provider/presentation/components/provider_hero.dart';
import 'package:local_markerplace/provider/presentation/components/rating_summary.dart';
import 'package:local_markerplace/provider/presentation/components/review_row.dart';
import 'package:local_markerplace/provider/presentation/components/segmented_tabs.dart';
import 'package:local_markerplace/provider/presentation/components/service_rows.dart';
import 'package:local_markerplace/provider/repository/provider_repository.dart';
import 'package:local_markerplace/store/model/cart_product.dart';
import 'package:local_markerplace/store/presentation/product_page.dart';
import 'package:local_markerplace/visit/model/visit_service.dart';
import 'package:local_markerplace/visit/presentation/add_to_visit_sheet.dart';
import 'package:local_markerplace/visit/presentation/your_visit_page.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

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
    this.localityName = 'Ajnara Gen X',
    this.repository = const ProviderRepository(),
    this.onTabSelected,
    this.onPost,
  });

  final String providerName;
  final bool isSignedIn;
  final ProviderTab initialTab;

  /// The seeker's own area, which the store's free-delivery line names.
  final String localityName;
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

  /// Adds one of the provider's services to the visit, then shows it.
  ///
  /// A visit is one provider, so adding from a different profile replaces
  /// whatever was being built — the sheet says so rather than silently
  /// dropping it.
  Future<void> _addToVisit(ProviderService service) async {
    final added = await showAddToVisitSheet(
      context,
      name: service.name,
      detail: service.detail,
      unitPrice: rupeesFrom(service.fromPrice),
    );
    if (added == null || !mounted) return;

    // Adding never displaces another store's cart: they sit side by side.
    VisitRepository.shared.addService(
      providerName: _profile.name,
      providerLine: '${widget.localityName} · usually replies in 10 min',
      isVerifiedProvider: _profile.isVerified,
      service: added,
    );
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => YourVisitPage(
          providerName: _profile.name,
          onAddAnother: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  /// Opens a part, and puts it in the cart if the seeker takes it.
  ///
  /// A cart is one provider, like a visit — adding from another store starts
  /// a new one, and the screen says so rather than losing the old one
  /// quietly.
  Future<void> _openProduct(StoreProduct product) async {
    final added = await Navigator.of(context).push<CartProduct>(
      MaterialPageRoute(
        builder: (_) => ProductPage(
          product: product,
          localityName: widget.localityName,
          onBookFitting: product.fittingName == null
              ? null
              : () => _bookFitting(product.fittingName!),
        ),
      ),
    );
    if (added == null || !mounted) return;

    VisitRepository.shared.addProduct(
      providerName: _profile.name,
      providerLine: '${widget.localityName} · usually replies in 10 min',
      isVerifiedProvider: _profile.isVerified,
      product: added,
    );
    if (!mounted) return;
    await _openCart();
  }

  /// Whether [service] is already on the visit being built with this
  /// provider — a service is one job, so it is on or off rather than
  /// counted.
  bool _onVisit(ProviderService service) {
    final visit = VisitRepository.shared.cartFor(_profile.name);
    if (visit == null) return false;
    return visit.services.any((booked) => booked.name == service.name);
  }

  void _removeFromVisit(ProviderService service) {
    final visits = VisitRepository.shared;
    final visit = visits.cartFor(_profile.name);
    if (visit == null) return;
    final index = visit.services.indexWhere((s) => s.name == service.name);
    if (index == -1) return;
    setState(() => visits.removeServiceAt(_profile.name, index));
  }

  /// How many of [product] are in this provider's cart. A cart belongs to
  /// one provider, so another store's count is not this grid's business.
  int _inCart(StoreProduct product) {
    final cart = VisitRepository.shared.cartFor(_profile.name);
    if (cart == null) return 0;
    for (final part in cart.parts) {
      if (part.name == product.name) return part.quantity;
    }
    return 0;
  }

  /// Adjusts a part's count straight from the grid. Stepping the last one
  /// down takes it out of the cart, which is what the bin on the button is
  /// promising.
  void _stepPart(StoreProduct product, int delta) {
    final visits = VisitRepository.shared;
    final cart = visits.cartFor(_profile.name);
    if (cart == null) return;
    final index = cart.parts.indexWhere((part) => part.name == product.name);
    if (index == -1) return;
    setState(
      () => visits.setPartQuantityAt(
        _profile.name,
        index,
        cart.parts[index].quantity + delta,
      ),
    );
  }

  Future<void> _openCart() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => YourVisitPage(
          providerName: _profile.name,
          onAddAnother: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  /// Leaves the store for the service that fits what is being bought. The
  /// two halves of a provider's page are the same person, so this is a tab
  /// switch rather than a new screen.
  void _bookFitting(String serviceName) {
    Navigator.of(context).pop();
    setState(() => _tab = ProviderTab.services);
    final match = _profile.services.where((s) => s.name == serviceName);
    if (match.isEmpty) return;
    _addToVisit(match.first);
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
      bottomNavigationBar: AppBottomBar(
        current: DiscoveryTab.explore,
        onSelect: (tab) => widget.onTabSelected?.call(tab),
        onPost: widget.onPost,
        // The store grid shows its own count, so it has to be rebuilt when
        // the cart is emptied from the bar.
        onCartChanged: () => setState(() {}),
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
        // Keyed on the tab so switching sections builds the list afresh and
        // its cards play their entrance, rather than the new section's
        // content appearing inside the old one's rows.
        key: ValueKey(_tab),
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => FadeSlideIn(
          index: index,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ServiceCard(
              service: services[index],
              isOnVisit: _onVisit(services[index]),
              onBook: widget.isSignedIn
                  ? () => _addToVisit(services[index])
                  : () => _gatedAction('book ${services[index].name}'),
              onRemove: () => _removeFromVisit(services[index]),
            ),
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

    // Only the cart this provider's parts are in — a cart belongs to one
    // provider, so another store's count would be a number about somebody
    // else.
    final cart = VisitRepository.shared.cartFor(_profile.name);
    final cartCount = cart?.partCount ?? 0;

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
              if (cartCount > 0)
                PressableScale(
                  onTap: _openCart,
                  pressedScale: 0.92,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.providerChipFill,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$cartCount in cart',
                      style: DiscoveryText.addChip,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid.builder(
          key: ValueKey(_tab),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 196,
          ),
          itemBuilder: (context, index) => FadeSlideIn(
            index: index,
            child: ProductCard(
              product: products[index],
              quantityInCart: _inCart(products[index]),
              onTap: () => _openProduct(products[index]),
              onAdd: widget.isSignedIn
                  ? () => _openProduct(products[index])
                  : () => _gatedAction('add ${products[index].name}'),
              onIncrement: () => _stepPart(products[index], 1),
              onDecrement: () => _stepPart(products[index], -1),
            ),
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
          key: ValueKey(_tab),
          itemCount: reviews.length,
          separatorBuilder: (_, _) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
          ),
          itemBuilder: (context, index) => FadeSlideIn(
            index: index,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, index == 0 ? 22 : 0, 20, 0),
              child: ReviewRow(review: reviews[index]),
            ),
          ),
        ),
    ];
  }

  List<Widget> _aboutBody() {
    return [
      SliverToBoxAdapter(
        key: ValueKey(_tab),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                child: Text(_profile.about, style: DiscoveryText.body),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                index: 1,
                child: MapThumbnail(onTap: () => _notice('Map — coming soon.')),
              ),
              const SizedBox(height: 22),
              FadeSlideIn(
                index: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Field(label: 'ADDRESS', value: _profile.address),
                    _Field(label: 'HOURS', value: _profile.hours),
                    _Field(
                      label: 'SERVES',
                      value: _profile.serves,
                      isLast: true,
                    ),
                  ],
                ),
              ),
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
