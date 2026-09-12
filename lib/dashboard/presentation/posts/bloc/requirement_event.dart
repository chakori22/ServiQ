part of 'requirement_bloc.dart';

sealed class RequirementEvent extends Equatable {
  const RequirementEvent();
}

final class RequirementOpened extends RequirementEvent {
  final PostDetails post;
  final String? currentUsername;
  final String? localityName;

  const RequirementOpened({
    required this.post,
    this.currentUsername,
    this.localityName,
  });

  @override
  List<Object?> get props => [post, currentUsername, localityName];
}

final class RequirementOfferMade extends RequirementEvent {
  final PostOffer offer;

  const RequirementOfferMade(this.offer);

  @override
  List<Object> get props => [offer];
}

/// Take this offer, and book the visit it describes.
final class RequirementOfferAccepted extends RequirementEvent {
  final PostOffer offer;

  const RequirementOfferAccepted(this.offer);

  @override
  List<Object> get props => [offer];
}

final class RequirementClosed extends RequirementEvent {
  const RequirementClosed();

  @override
  List<Object> get props => [];
}

/// The receipt for the booking has been shown.
final class RequirementBookingSeen extends RequirementEvent {
  const RequirementBookingSeen();

  @override
  List<Object> get props => [];
}
