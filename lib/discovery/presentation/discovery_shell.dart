import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/core/app_routes.dart';
import 'package:local_markerplace/discovery/model/locality.dart';
import 'package:local_markerplace/discovery/model/service_zone.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/discovery_home_view.dart';
import 'package:local_markerplace/discovery/presentation/explore_zones_view.dart';
import 'package:local_markerplace/discovery/presentation/location_page.dart';
import 'package:local_markerplace/discovery/presentation/locality_page.dart';
import 'package:local_markerplace/discovery/presentation/search_page.dart';
import 'package:local_markerplace/discovery/presentation/zone_detail_page.dart';
import 'package:local_markerplace/discovery/repository/discovery_repository.dart';
import 'package:local_markerplace/onboarding/repository/onboarding_repository.dart';

/// Hosts the two tabbed discovery screens and owns the state they share —
/// which area the seeker is browsing, and which tab is showing.
///
/// The drill-down screens (zone detail, locality, search) are pushed on top
/// of this rather than being tabs of their own, which is why they draw their
/// own copy of the tab bar and route back through [_selectTab].
class DiscoveryShell extends StatefulWidget {
  const DiscoveryShell({
    super.key,
    this.initialTab = DiscoveryTab.home,
    this.initialLocality,
    this.repository = const DiscoveryRepository(),
    this.profiles,
  });

  final DiscoveryTab initialTab;

  /// The area to open on. Null falls back to the area onboarding recorded in
  /// [profiles], and only then to the picker.
  final String? initialLocality;

  final DiscoveryRepository repository;

  /// Where the seeker's profile lives. The area they chose during onboarding
  /// is read from it on launch, and a change made here is written back — so a
  /// returning seeker lands straight on the area they were last browsing
  /// instead of being asked again.
  ///
  /// Null in tests and anywhere the profile is not provided, which simply
  /// means the picker opens.
  final OnboardingRepository? profiles;

  @override
  State<DiscoveryShell> createState() => _DiscoveryShellState();
}

class _DiscoveryShellState extends State<DiscoveryShell> {
  late DiscoveryTab _tab = widget.initialTab;
  late String? _localityName = widget.initialLocality;

  /// Held back until the stored profile has been read, so the picker is not
  /// flashed at a seeker who already told onboarding where they live.
  bool _resolvingLocality = false;

  @override
  void initState() {
    super.initState();
    if (_localityName == null) {
      _resolveLocality();
    }
  }

  /// Falls back through the places an area can come from: the profile
  /// onboarding saved, then asking.
  Future<void> _resolveLocality() async {
    final profiles = widget.profiles;
    if (profiles != null) {
      setState(() => _resolvingLocality = true);
      final profile = await profiles.readProfile();
      if (!mounted) return;
      final locality = profile?.locality ?? '';
      setState(() => _resolvingLocality = false);
      if (locality.isNotEmpty) {
        setState(() => _localityName = locality);
        return;
      }
    }
    // Nothing on file — a seeker who skipped onboarding, or a fresh install.
    // Deferred to the next frame because it is a route push, not a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pickLocality();
    });
  }

  Future<void> _pickLocality() async {
    final locality = await Navigator.of(context).push<Locality>(
      MaterialPageRoute(
        builder: (_) => LocationPage(repository: widget.repository),
      ),
    );
    if (!mounted || locality == null) return;
    setState(() => _localityName = locality.name);
    await _rememberLocality(locality.name);
  }

  /// Writes the chosen area back to the profile so the next launch opens on
  /// it. A failure here is not worth interrupting browsing for — the seeker
  /// simply gets asked again next time.
  Future<void> _rememberLocality(String name) async {
    final profiles = widget.profiles;
    if (profiles == null) return;
    final profile = await profiles.readProfile();
    if (profile == null || profile.locality == name) return;
    await profiles.saveProfile(profile.copyWith(locality: name));
  }

  void _selectTab(DiscoveryTab tab) {
    switch (tab) {
      case DiscoveryTab.home:
      case DiscoveryTab.explore:
      case DiscoveryTab.me:
        setState(() => _tab = tab);
      case DiscoveryTab.posts:
        // Posts already has a screen of its own outside this flow, so the
        // tab opens it rather than duplicating it here.
        GoRouter.of(context).pushAppRoute(AppRoutes.posts);
    }
  }

  /// Sends a drill-down screen's tab tap back to the shell underneath it.
  void _selectTabFromChild(DiscoveryTab tab) {
    if (tab == DiscoveryTab.posts) {
      GoRouter.of(context).pushAppRoute(AppRoutes.posts);
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tab = tab);
  }

  void _openPostForm() =>
      GoRouter.of(context).pushAppRoute(AppRoutes.instantForm);

  void _openZone(ServiceZone zone) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ZoneDetailPage(
          zone: zone,
          onLocalityTap: _openLocality,
          onTabSelected: _selectTabFromChild,
          onPost: _openPostForm,
        ),
      ),
    );
  }

  void _openLocality(Locality locality) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocalityPage(
          localityName: locality.name,
          repository: widget.repository,
          onTabSelected: _selectTabFromChild,
          onPost: _openPostForm,
        ),
      ),
    );
  }

  void _openSearch() {
    final locality = _localityName;
    if (locality == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchPage(
          localityName: locality,
          repository: widget.repository,
          onTabSelected: _selectTabFromChild,
          onPost: _openPostForm,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvingLocality) {
      // A single frame or two while secure storage is read.
      return const Scaffold(
        backgroundColor: AppColor.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColor.discoveryAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(bottom: false, child: _body()),
      bottomNavigationBar: DiscoveryTabBar(
        current: _tab,
        onSelect: _selectTab,
        onPost: _openPostForm,
      ),
    );
  }

  Widget _body() {
    switch (_tab) {
      case DiscoveryTab.home:
        // Until an area is chosen the picker is on top of this anyway, so
        // the header falls back to a neutral label rather than a real one.
        return DiscoveryHomeView(
          localityName: _localityName ?? 'Choose your area',
          repository: widget.repository,
          onChangeLocality: _pickLocality,
          onSearch: _openSearch,
          onSeeAllCategories: () => setState(() => _tab = DiscoveryTab.explore),
          onSeeAllProviders: () {
            final locality = _localityName;
            if (locality != null) {
              _openLocality(
                Locality(
                  name: locality,
                  providerCount: widget.repository.providersIn(locality).length,
                  kind: LocalityKind.society,
                ),
              );
            }
          },
        );
      case DiscoveryTab.explore:
        return ExploreZonesView(
          repository: widget.repository,
          onZoneTap: _openZone,
          onComingSoonTap: (zone) => showComingSoonNotice(context, zone),
        );
      case DiscoveryTab.posts:
      case DiscoveryTab.me:
        // "Me" has no design in this flow yet; the tab is here so the bar
        // matches the mock, and says so rather than showing a blank page.
        return Center(
          child: Text('Coming soon', style: DiscoveryText.subtitle),
        );
    }
  }
}
