import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/model/provider_summary.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_filter_chip.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_search_field.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/discovery/presentation/components/provider_row.dart';
import 'package:local_markerplace/discovery/repository/discovery_repository.dart';

/// 06 · Search — typing, filters and results, all on one screen.
///
/// The trade chips are built from the trades actually present in the current
/// locality, so the row never offers a filter that would return nothing.
class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.localityName,
    this.initialQuery = '',
    this.onProviderTap,
    this.onTabSelected,
    this.onPost,
    this.repository = const DiscoveryRepository(),
  });

  final String localityName;
  final String initialQuery;
  final ValueChanged<ProviderSummary>? onProviderTap;
  final ValueChanged<DiscoveryTab>? onTabSelected;
  final VoidCallback? onPost;
  final DiscoveryRepository repository;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery,
  );

  /// Null means the "All" chip is on.
  String? _trade;

  /// The rating floor the scope chip applies. Null until the seeker sets one.
  double? _minRating;

  static const _ratingSteps = <double?>[null, 4.0, 4.5];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cycleRating() {
    final next = (_ratingSteps.indexOf(_minRating) + 1) % _ratingSteps.length;
    setState(() => _minRating = _ratingSteps[next]);
  }

  @override
  Widget build(BuildContext context) {
    final trades = widget.repository.tradesIn(widget.localityName);
    final results = widget.repository.search(
      _controller.text,
      trade: _trade,
      minRating: _minRating,
      localityName: widget.localityName,
    );

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: SvgPicture.asset(
                      DiscoveryAssets.backPlain,
                      width: 32,
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DiscoverySearchField(
                      controller: _controller,
                      onChanged: (_) => setState(() {}),
                      onClear: () {
                        _controller.clear();
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  DiscoveryFilterChip(
                    label: 'All',
                    isSelected: _trade == null,
                    onTap: () => setState(() => _trade = null),
                  ),
                  for (final trade in trades) ...[
                    const SizedBox(width: 8),
                    DiscoveryFilterChip(
                      label: trade,
                      isSelected: _trade == trade,
                      onTap: () => setState(() => _trade = trade),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  DiscoveryFilterChip(
                    label: widget.localityName,
                    hasCaret: true,
                    // Changing the area is the area picker's job, so this
                    // hands the screen back rather than filtering in place.
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 8),
                  DiscoveryFilterChip(
                    label: _minRating == null
                        ? 'Any rating'
                        : '${_minRating!.toStringAsFixed(1)}+',
                    hasCaret: true,
                    onTap: _cycleRating,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                '${results.length} '
                '${results.length == 1 ? 'result' : 'results'} '
                'in ${widget.localityName}',
                style: DiscoveryText.footnoteStrong,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: results.length,
                separatorBuilder: (_, _) => const Padding(
                  padding: EdgeInsets.only(left: 58),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColor.discoveryBorder,
                  ),
                ),
                itemBuilder: (context, index) {
                  final provider = results[index];
                  return ProviderRow(
                    provider: provider,
                    showReviewCount: false,
                    subtitle:
                        '${provider.localityName} · '
                        '${provider.isOpen ? 'Open now' : 'Closed'}',
                    onTap: () => widget.onProviderTap?.call(provider),
                  );
                },
              ),
            ),
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
}
