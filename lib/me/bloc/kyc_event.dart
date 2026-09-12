part of 'kyc_bloc.dart';

sealed class KycEvent extends Equatable {
  const KycEvent();
}

/// Read what has been submitted, and open the form on the first type.
final class KycRequested extends KycEvent {
  const KycRequested();

  @override
  List<Object> get props => [];
}

final class KycTypeSelected extends KycEvent {
  final String type;

  const KycTypeSelected(this.type);

  @override
  List<Object> get props => [type];
}

/// One side of the document was added or taken away again.
final class KycSideChanged extends KycEvent {
  final KycSide side;
  final bool isAdded;

  const KycSideChanged({required this.side, required this.isAdded});

  @override
  List<Object> get props => [side, isAdded];
}
