import 'package:flutter/material.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/provider/model/provider_service.dart';

/// A service in the short list on the profile head — a plain divided row,
/// with the visit charge underneath.
class ServiceSummaryRow extends StatelessWidget {
  const ServiceSummaryRow({super.key, required this.service, this.onTap});

  final ProviderService service;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 62,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DiscoveryText.rowTitle,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DiscoveryText.metaMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(service.fromPrice, style: DiscoveryText.price),
            ),
          ],
        ),
      ),
    );
  }
}

/// A service on the Services tab — a card carrying what the job covers and a
/// Book action.
class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, this.onBook});

  final ProviderService service;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13.2, 11.2, 13.2, 11.2),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColor.discoveryShadow.withValues(alpha: 0.05),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                  style: DiscoveryText.sectionTitleSmall,
                ),
              ),
              const SizedBox(width: 12),
              Text(service.fromPrice, style: DiscoveryText.price),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            service.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DiscoveryText.metaMuted,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onBook,
              behavior: HitTestBehavior.opaque,
              child: Text('Book', style: DiscoveryText.bookLink),
            ),
          ),
        ],
      ),
    );
  }
}
