import 'package:equatable/equatable.dart';

/// Where a submitted document has got to.
///
/// [pending] is the account-level state shown on the Me row when nothing has
/// been approved yet; the other three belong to individual documents.
enum KycStatus {
  approved('APPROVED'),
  underReview('UNDER REVIEW'),
  rejected('REJECTED'),
  pending('PENDING');

  const KycStatus(this.label);

  final String label;
}

/// One identity document the seeker has submitted.
class KycDocument extends Equatable {
  const KycDocument({
    required this.type,
    required this.status,
    required this.statusLine,
    this.rejectionReason,
  });

  /// "Aadhaar", "PAN", "Driving Licence".
  final String type;

  final KycStatus status;

  /// "Verified 12 Aug 2026", "Submitted 2 days ago".
  final String statusLine;

  /// The reviewer's note, quoted back to the seeker word for word so they can
  /// fix exactly what was wrong.
  final String? rejectionReason;

  bool get isRejected => status == KycStatus.rejected;

  @override
  List<Object?> get props => [type, status, statusLine, rejectionReason];
}
