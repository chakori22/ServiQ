import 'package:equatable/equatable.dart';

/// One bookable job a provider offers.
class ProviderService extends Equatable {
  const ProviderService({
    required this.name,
    required this.fromPrice,
    required this.detail,
  });

  final String name;

  /// Already formatted, e.g. "from ₹499".
  final String fromPrice;

  /// The line under the name. On the profile's summary list this is the visit
  /// charge; on the Services tab it is what the job covers.
  final String detail;

  @override
  List<Object?> get props => [name, fromPrice, detail];
}
