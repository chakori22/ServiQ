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
import 'package:local_markerplace/discovery/model/provider_summary.dart';
import 'package:local_markerplace/discovery/repository/discovery_repository.dart';
import 'package:local_markerplace/provider/presentation/provider_profile_page.dart';
import 'package:local_markerplace/me/model/saved_provider.dart';
import 'package:local_markerplace/me/presentation/addresses_page.dart';
import 'package:local_markerplace/me/presentation/edit_profile_page.dart';
import 'package:local_markerplace/me/presentation/kyc_pages.dart';
import 'package:local_markerplace/me/presentation/me_page.dart';
import 'package:local_markerplace/me/presentation/picture_picker_sheet.dart';
import 'package:local_markerplace/me/presentation/saved_providers_page.dart';
import 'package:local_markerplace/me/presentation/sign_out.dart';
import 'package:local_markerplace/me/repository/me_repository.dart';
import 'package:local_markerplace/onboarding/model/seeker_profile.dart';
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
    this.meRepository = const MeRepository(),
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

  /// Everything the Me tab and its screens read.
  final MeRepository meRepository;

  @override
  State<DiscoveryShell> createState() => _DiscoveryShellState();
}

class _DiscoveryShellState extends State<DiscoveryShell> {
  late DiscoveryTab _tab = widget.initialTab;
  late String? _localityName = widget.initialLocality;

  /// Held back until the stored profile has been read, so the picker is not
  /// flashed at a seeker who already told onboarding where they live.
  bool _resolvingLocality = false;

  /// The profile behind the Me tab. Null until it has been read, or when
  /// there is none on file.
  SeekerProfile? _profile;

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
      setState(() {
        _resolvingLocality = false;
        _profile = profile;
      });
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

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
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

  /// Writes an edited profile back and refreshes the Me tab with it.
  Future<void> _saveProfile(String name, Set<String> interestLabels) async {
    final profiles = widget.profiles;
    final current = _profile ?? const SeekerProfile();
    final ids = seekerServiceInterests
        .where((interest) => interestLabels.contains(interest.label))
        .map((interest) => interest.id)
        .toSet();
    final updated = current.copyWith(fullName: name, interestIds: ids);

    setState(() => _profile = updated);
    await profiles?.saveProfile(updated);
  }

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
          onProviderTap: _openProvider,
          onTabSelected: _selectTabFromChild,
          onPost: _openPostForm,
        ),
      ),
    );
  }

  /// Every list of providers in the flow ends here.
  void _openProvider(ProviderSummary provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderProfilePage(
          providerName: provider.name,
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
          onProviderTap: _openProvider,
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

  Widget _meView() {
    final account = widget.meRepository.account(profile: _profile);

    return MeView(
      account: account,
      onEditProfile: () => _push(
        EditProfilePage(
          account: account,
          onSave: _saveProfile,
          onChangePhoto: _pickPicture,
          onPickLocality: _pickLocality,
        ),
      ),
      onVisits: () => _notice('My visits — coming soon.'),
      onPosts: () => GoRouter.of(context).pushAppRoute(AppRoutes.posts),
      onChats: () => _notice('Chats — coming soon.'),
      onIdentity: () => _push(KycListPage(repository: widget.meRepository)),
      onSavedProviders: () => _push(
        SavedProvidersPage(
          localityName: _localityName ?? account.localityName,
          repository: widget.meRepository,
          onProviderTap: _openSavedProvider,
          onTabSelected: _selectTabFromChild,
          onPost: _openPostForm,
        ),
      ),
      onAddresses: () => _push(
        AddressesPage(
          repository: widget.meRepository,
          onTabSelected: _selectTabFromChild,
          onPost: _openPostForm,
        ),
      ),
      onNotifications: () => _notice('Notification settings — coming soon.'),
      onBecomeProvider: () => _notice('Listing your business — coming soon.'),
      onSignOut: () => confirmSignOut(context, everywhere: false),
      onSignOutEverywhere: () => confirmSignOut(context, everywhere: true),
    );
  }

  Future<void> _pickPicture() async {
    final action = await PicturePickerSheet.show(context);
    if (action == null || !mounted) return;
    _notice('${action.name} — coming soon.');
  }

  void _openSavedProvider(SavedProvider provider) {
    _push(
      ProviderProfilePage(
        providerName: provider.name,
        onTabSelected: _selectTabFromChild,
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
          onProviderTap: _openProvider,
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
      case DiscoveryTab.me:
        return _meView();
      case DiscoveryTab.posts:
        // Posts opens its own screen rather than rendering here; this only
        // shows if the tab is somehow current.
        return const SizedBox.shrink();
    }
  }
}
