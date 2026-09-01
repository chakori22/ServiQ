part of 'post_bloc.dart';

class PostState extends Equatable {
  final String errorMessage;
  final List<PostDetails> postDetails;
  final bool postsLoading;

  /// The post currently being uploaded, or null when nothing is in flight.
  /// While it is set, the page shows the progress banner above the feed.
  final PostDraft? uploadingDraft;

  /// How far [uploadingDraft] has got, from 0 to 1.
  final double uploadProgress;

  const PostState({
    required this.errorMessage,
    required this.postDetails,

    required this.postsLoading,
    required this.uploadingDraft,
    required this.uploadProgress,
  });

  const PostState.initial({
    this.errorMessage = '',
    this.postDetails = const [],
    this.postsLoading = false,
    this.uploadingDraft,
    this.uploadProgress = 0,
  });

  PostState copyWith({
    String? errorMessage,
    List<PostDetails>? postDetails,
    List<PostDetails>? filteredPostDetails,
    bool? postsLoading,
    PostDraft? uploadingDraft,
    /// Set when the upload has finished or failed — a null [uploadingDraft]
    /// otherwise means "unchanged", which would leave the banner up forever.
    bool clearUploadingDraft = false,
    double? uploadProgress,
  }) {
    return PostState(
      errorMessage: errorMessage ?? this.errorMessage,
      postDetails: postDetails ?? this.postDetails,
      postsLoading: postsLoading ?? this.postsLoading,
      uploadingDraft: clearUploadingDraft
          ? null
          : uploadingDraft ?? this.uploadingDraft,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  /// True while a post is on its way to the server.
  bool get isUploading => uploadingDraft != null;

  /// Progress as the banner shows it, e.g. "53.0%".
  String get uploadProgressText =>
      '${(uploadProgress * 100).toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [
    errorMessage,
    postDetails,
    postsLoading,
    uploadingDraft,
    uploadProgress,
  ];
}
