import 'package:flutter/material.dart';

import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// The line shown where a list would otherwise be blank — an area ServiQ
/// covers but has nobody on file for yet.
///
/// An empty section is indistinguishable from a screen that failed to load,
/// so every list in the flow says why it is empty rather than showing nothing.
class DiscoveryNote extends StatelessWidget {
  const DiscoveryNote(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        message,
        style: DiscoveryText.footnote.copyWith(height: 18 / 12),
      ),
    );
  }
}
