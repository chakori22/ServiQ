import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// One tile in the home screen's category grid.
class ServiceCategory extends Equatable {
  const ServiceCategory({required this.label, this.iconAsset = '', this.icon})
    : assert(
        iconAsset != '' || icon != null,
        'a tile needs either a bundled asset or an icon to draw',
      );

  final String label;

  /// Path of the bundled glyph drawn inside the tile's white disc. Empty
  /// when the category came from the server, which names an icon instead of
  /// shipping one.
  final String iconAsset;

  /// Drawn when there is no [iconAsset] — the server's icon name, resolved.
  final IconData? icon;

  @override
  List<Object?> get props => [label, iconAsset, icon];
}
