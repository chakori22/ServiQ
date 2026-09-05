import 'package:equatable/equatable.dart';

/// One tile in the home screen's category grid.
class ServiceCategory extends Equatable {
  const ServiceCategory({required this.label, required this.iconAsset});

  final String label;

  /// Path of the glyph drawn inside the tile's white disc.
  final String iconAsset;

  @override
  List<Object?> get props => [label, iconAsset];
}
