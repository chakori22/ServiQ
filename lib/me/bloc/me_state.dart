part of 'me_bloc.dart';

class MeState extends Equatable {
  final SeekerAccount? account;
  final SeekerProfile? profile;
  final bool isLoading;

  const MeState({
    required this.account,
    required this.profile,
    required this.isLoading,
  });

  const MeState.initial({this.account, this.profile, this.isLoading = true});

  MeState copyWith({
    SeekerAccount? account,
    SeekerProfile? profile,
    bool? isLoading,
  }) {
    return MeState(
      account: account ?? this.account,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [account, profile, isLoading];
}
