part of 'kyc_bloc.dart';

/// Which face of the document a change is about.
enum KycSide { front, back }

class KycState extends Equatable {
  /// What has already been submitted.
  final List<KycDocument> documents;

  /// The kinds of document that can be submitted.
  final List<String> types;

  /// The submission being prepared.
  final String type;
  final bool hasFront;
  final bool hasBack;

  final bool isLoading;

  const KycState({
    required this.documents,
    required this.types,
    required this.type,
    required this.hasFront,
    required this.hasBack,
    required this.isLoading,
  });

  const KycState.initial({
    this.documents = const [],
    this.types = const [],
    this.type = '',
    this.hasFront = true,
    this.hasBack = false,
    this.isLoading = true,
  });

  KycState copyWith({
    List<KycDocument>? documents,
    List<String>? types,
    String? type,
    bool? hasFront,
    bool? hasBack,
    bool? isLoading,
  }) {
    return KycState(
      documents: documents ?? this.documents,
      types: types ?? this.types,
      type: type ?? this.type,
      hasFront: hasFront ?? this.hasFront,
      hasBack: hasBack ?? this.hasBack,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Both sides or nothing: a document with one face is not a document.
  bool get canSubmit => hasFront && hasBack;

  @override
  List<Object?> get props => [
    documents,
    types,
    type,
    hasFront,
    hasBack,
    isLoading,
  ];
}
