import 'package:flutter/material.dart';

import 'package:local_markerplace/components/art/seeded_artwork.dart';
import 'package:local_markerplace/components/motion/app_motion.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/basket/basket.dart';
import 'package:local_markerplace/discovery/model/catalogue_service.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_filter_chip.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/pending_booking_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_avatar.dart';
import 'package:local_markerplace/discovery/repository/discovery_repository.dart';
import 'package:local_markerplace/provider/repository/provider_repository.dart';
import 'package:local_markerplace/visit/model/visit_service.dart';
import 'package:local_markerplace/visit/presentation/add_to_visit_sheet.dart';
import 'package:local_markerplace/visit/presentation/your_visit_page.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

/// Everything bookable in the seeker's area, in one list.
///
/// Home's category tiles are a way into this rather than six separate
/// screens: the catalogue is flat and a chip narrows it, so "See all" and a
/// tap on "Plumber" land in the same place with a different chip lit.
///
/// Adding here puts the job on the visit, which is where a service lives —
/// a part goes in the cart, a service becomes a trip.
class ServicesPage extends StatefulWidget {
  const ServicesPage({
    super.key,
    required this.localityName,
    this.initialCategory,
    this.repository = const DiscoveryRepository(),
    this.providers = const ProviderRepository(),
    this.visits,
  });

  final String localityName;

  /// The tile that was tapped, or null for "See all".
  final String? initialCategory;

  final DiscoveryRepository repository;

  /// Where the catalogue comes from: each provider's own service list, so
  /// the prices here are the prices on their page.
  final ProviderRepository providers;

  final VisitRepository? visits;

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  late final VisitRepository _visits = widget.visits ?? VisitRepository.shared;

  late String? _category = widget.initialCategory;

  List<CatalogueService> get _services => widget.providers.servicesIn(
    widget.localityName,
    categoryLabel: _category,
  );

  /// How many of [service] are already on the visit, so the row can offer to
  /// take it off again rather than add a second one.
  int _onVisit(CatalogueService service) {
    final visit = _visits.current;
    if (visit == null || visit.providerName != service.providerName) return 0;
    for (final booked in visit.services) {
      if (booked.name == service.name) return booked.quantity;
    }
    return 0;
  }

  Future<void> _add(CatalogueService service) async {
    final added = await showAddToVisitSheet(
      context,
      name: service.name,
      detail: service.detail,
      unitPrice: rupeesFrom(service.fromPrice),
    );
    if (added == null || !mounted) return;

    final replaced = _visits.addService(
      providerName: service.providerName,
      providerLine: service.providerLine(widget.localityName),
      isVerifiedProvider: service.isVerifiedProvider,
      service: added,
    );
    if (replaced) {
      _notice('Started a new visit with ${service.providerName}.');
    }
    setState(() {});
  }

  /// Takes the job back off the visit. The list is the only place it can be
  /// removed from without opening the visit itself, so the row keeps the
  /// action once something is on it.
  void _remove(CatalogueService service) {
    final visit = _visits.current;
    if (visit == null) return;
    final index = visit.services.indexWhere((s) => s.name == service.name);
    if (index == -1) return;
    setState(() => _visits.removeServiceAt(index));
  }

  Future<void> _openVisit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => YourVisitPage(repository: _visits)),
    );
    if (mounted) setState(() {});
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
    final services = _services;
    final cart = currentBasket(visits: _visits);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DiscoveryHeader(
              title: 'Services',
              subtitle:
                  '${services.length} '
                  '${services.length == 1 ? 'job' : 'jobs'} in '
                  '${widget.localityName}',
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  DiscoveryFilterChip(
                    label: 'All',
                    isSelected: _category == null,
                    onTap: () => setState(() => _category = null),
                  ),
                  for (final category in widget.repository.categories()) ...[
                    const SizedBox(width: 8),
                    DiscoveryFilterChip(
                      label: category.label,
                      isSelected: _category == category.label,
                      onTap: () => setState(() => _category = category.label),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
            Expanded(
              child: services.isEmpty
                  ? const _NoServices()
                  : ListView.separated(
                      // Keyed on the chip so switching categories builds the
                      // list afresh and its rows play their entrance.
                      key: ValueKey(_category),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: services.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => FadeSlideIn(
                        index: index,
                        child: CatalogueServiceCard(
                          service: services[index],
                          quantityOnVisit: _onVisit(services[index]),
                          onAdd: () => _add(services[index]),
                          onRemove: () => _remove(services[index]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: cart == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: PendingBookingBar(booking: cart, onView: _openVisit),
              ),
            ),
    );
  }
}

/// One job in the catalogue: what it is, who does it, and the way on or off
/// the visit.
class CatalogueServiceCard extends StatelessWidget {
  const CatalogueServiceCard({
    super.key,
    required this.service,
    required this.quantityOnVisit,
    required this.onAdd,
    required this.onRemove,
  });

  final CatalogueService service;

  /// Zero when the job is not on the visit; the count when it is, which is
  /// what turns Add into a way to take it off.
  final int quantityOnVisit;

  final VoidCallback onAdd;
  final VoidCallback onRemove;

  bool get _isOnVisit => quantityOnVisit > 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.quick,
      curve: AppMotion.emphasized,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isOnVisit
              ? AppColor.discoveryAccent
              : AppColor.discoveryBorder,
          width: _isOnVisit ? 2 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.discoveryShadow.withValues(alpha: 0.05),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: SeededArtwork(
              seed: service.name,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DiscoveryText.offerName,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(service.fromPrice, style: DiscoveryText.fromPrice),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  service.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: DiscoveryText.smallPrint,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ProviderAvatar(
                      initials: _initials(service.providerName),
                      seed: service.providerName,
                      size: 22,
                      isVerified: service.isVerifiedProvider,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        service.providerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DiscoveryText.meta,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: AppColor.discoveryStar,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      service.rating.toStringAsFixed(1),
                      style: DiscoveryText.meta,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  // A service is one job, not a quantity to step through, so
                  // once it is on the visit the row offers to take it off
                  // rather than to add another.
                  child: _isOnVisit
                      ? _RemoveButton(onTap: onRemove)
                      : _AddButton(onTap: onAdd),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.9,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: AppColor.providerChipFill,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text('Add', style: DiscoveryText.addChip),
      ),
    );
  }
}

/// "In cart", with the bin that takes it back out.
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'In cart',
          style: DiscoveryText.addChip.copyWith(
            color: AppColor.discoveryLiveText,
          ),
        ),
        const SizedBox(width: 8),
        PressableScale(
          onTap: onTap,
          pressedScale: 0.85,
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.stockLowTint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: AppColor.authError,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoServices extends StatelessWidget {
  const _NoServices();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        'Nothing listed under this category yet. Post what you need and '
        'providers will answer.',
        textAlign: TextAlign.center,
        style: DiscoveryText.footnoteStrong.copyWith(height: 18 / 12),
      ),
    ),
  );
}

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.isEmpty || words.first.isEmpty) return '?';
  if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
  return (words[0][0] + words[1][0]).toUpperCase();
}
