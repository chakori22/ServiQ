import 'package:equatable/equatable.dart';

/// An address the seeker has saved for visits and deliveries.
class SavedAddress extends Equatable {
  const SavedAddress({
    required this.label,
    required this.lines,
    this.isDefault = false,
    this.isServiceable = true,
  });

  /// "Home", "Office", "Mum".
  final String label;

  /// The address itself, already broken where the design breaks it.
  final String lines;

  final bool isDefault;

  /// False for an address outside a live locality, which cannot be delivered
  /// to — the card says so rather than failing at checkout.
  final bool isServiceable;

  @override
  List<Object?> get props => [label, lines, isDefault, isServiceable];
}
