import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/model/post_offer.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/components/requirement_card.dart';
import 'package:local_markerplace/dashboard/repository/post_offer_repository.dart';
import 'package:local_markerplace/visit/model/visit.dart';
import 'package:local_markerplace/visit/model/visit_service.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

part 'requirement_event.dart';
part 'requirement_state.dart';

/// One requirement on the board: the offers on it, and what the seeker does
/// about them.
///
/// Taking an offer books the visit outright. Everything the visit flow
/// normally asks for was settled by the offer itself — the provider named
/// the price and the time, and accepting agreed to both — so the booking
/// happens here rather than being asked for again.
class RequirementBloc extends Bloc<RequirementEvent, RequirementState> {
  final PostOfferRepository offerRepository;
  final VisitRepository visitRepository;

  RequirementBloc({
    required this.offerRepository,
    required this.visitRepository,
  }) : super(const RequirementState.initial()) {
    on<RequirementOpened>(_onOpened);
    on<RequirementOfferMade>(_onOfferMade);
    on<RequirementOfferAccepted>(_onOfferAccepted);
    on<RequirementClosed>(_onClosed);
    on<RequirementBookingSeen>(_onBookingSeen);
  }

  void _onOpened(RequirementOpened event, Emitter<RequirementState> emit) {
    emit(
      state.copyWith(
        post: event.post,
        currentUsername: event.currentUsername,
        localityName: event.localityName,
        offers: offerRepository.offersOn(event.post),
        isLoading: false,
      ),
    );
  }

  void _onOfferMade(
    RequirementOfferMade event,
    Emitter<RequirementState> emit,
  ) {
    final post = state.post;
    if (post == null) return;
    offerRepository.add(post, event.offer);
    final updated = post.copyWith(acceptCount: post.acceptCount + 1);
    emit(
      state.copyWith(post: updated, offers: offerRepository.offersOn(updated)),
    );
  }

  void _onOfferAccepted(
    RequirementOfferAccepted event,
    Emitter<RequirementState> emit,
  ) {
    final post = state.post;
    if (post == null) return;
    final offer = event.offer;
    final updated = post.copyWith(isAccepted: true, acceptedBy: offer.name);

    final booked = visitRepository.bookFromOffer(
      providerName: offer.name,
      providerLine: [?state.localityName, 'agreed ${offer.price}'].join(' · '),
      isVerifiedProvider: offer.badge == OfferBadge.verified,
      agreedWhen: _capitalised(offer.timing),
      service: VisitService(
        name: requirementHeadline(updated.description),
        detail: requirementDetail(updated.description) ?? '',
        unitPrice: rupeesFrom(offer.price),
      ),
    );

    emit(state.copyWith(post: updated, booked: booked));
  }

  /// Closing is separate from accepting — a job can be settled, or simply no
  /// longer needed.
  void _onClosed(RequirementClosed event, Emitter<RequirementState> emit) {
    final post = state.post;
    if (post == null) return;
    emit(state.copyWith(post: post.copyWith(isClosed: true)));
  }

  void _onBookingSeen(
    RequirementBookingSeen event,
    Emitter<RequirementState> emit,
  ) {
    emit(state.copyWith(booked: null));
  }

  /// Offers are written mid-sentence ("today, 4 – 6 pm"); the booked screen
  /// shows the timing as a heading of its own.
  static String _capitalised(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
