part of 'requirement_bloc.dart';

// Sentinel so copyWith can tell "not passed" apart from an explicit null.
const _unset = Object();

class RequirementState extends Equatable {
  /// The page's own copy, so accepting settles it here immediately rather
  /// than waiting for the board underneath to rebuild.
  final PostDetails? post;

  final List<PostOffer> offers;

  /// Who is signed in, which decides whether the accept buttons are theirs
  /// to press.
  final String? currentUsername;

  final String? localityName;

  final bool isLoading;

  /// A visit just booked by accepting, waiting for its receipt to be shown.
  final Visit? booked;

  const RequirementState({
    required this.post,
    required this.offers,
    required this.currentUsername,
    required this.localityName,
    required this.isLoading,
    required this.booked,
  });

  const RequirementState.initial({
    this.post,
    this.offers = const [],
    this.currentUsername,
    this.localityName,
    this.isLoading = true,
    this.booked,
  });

  RequirementState copyWith({
    PostDetails? post,
    List<PostOffer>? offers,
    String? currentUsername,
    String? localityName,
    bool? isLoading,
    Object? booked = _unset,
  }) {
    return RequirementState(
      post: post ?? this.post,
      offers: offers ?? this.offers,
      currentUsername: currentUsername ?? this.currentUsername,
      localityName: localityName ?? this.localityName,
      isLoading: isLoading ?? this.isLoading,
      booked: booked == _unset ? this.booked : booked as Visit?,
    );
  }

  /// Only the seeker who posted it can take an offer on it.
  bool get isMine => post?.isPostedBy(currentUsername) ?? false;

  @override
  List<Object?> get props => [
    post,
    offers,
    currentUsername,
    localityName,
    isLoading,
    booked,
  ];
}
