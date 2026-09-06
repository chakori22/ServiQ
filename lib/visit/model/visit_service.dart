import 'package:equatable/equatable.dart';

// Prices are read and written all over the visit flow; re-exporting keeps
// `rupees` reachable from a `visit_service.dart` import, which is where the
// flow already looks for them.
export 'package:local_markerplace/core/money.dart' show rupees, rupeesFrom;

/// One service on a visit: what it is, how many of it, and anything the
/// seeker wants the provider to know before turning up.
class VisitService extends Equatable {
  const VisitService({
    required this.name,
    required this.detail,
    required this.unitPrice,
    this.quantity = 1,
    this.note = '',
  });

  final String name;

  /// What the service covers, shown when it is being added.
  final String detail;

  /// Rupees for one of it.
  final double unitPrice;

  final int quantity;

  /// "Bedroom unit rattles." Empty when nothing was said.
  final String note;

  double get lineTotal => unitPrice * quantity;

  /// "× 2 units" / "× 1".
  String get quantityLabel => quantity == 1 ? '× 1' : '× $quantity units';

  VisitService copyWith({int? quantity, String? note}) => VisitService(
    name: name,
    detail: detail,
    unitPrice: unitPrice,
    quantity: quantity ?? this.quantity,
    note: note ?? this.note,
  );

  @override
  List<Object?> get props => [name, detail, unitPrice, quantity, note];
}
