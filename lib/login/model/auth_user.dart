/// The signed-in user, from the `user` block of OTP verification.
class AuthUser {
  final String userId;
  final String username;
  final String countryCode;
  final String phoneNumber;
  final String role;
  final bool verified;

  /// Null until the user uploads a picture.
  final String? profilePictureFileId;

  const AuthUser({
    required this.userId,
    required this.username,
    required this.countryCode,
    required this.phoneNumber,
    required this.role,
    required this.verified,
    this.profilePictureFileId,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? '',
      verified: json['verified'] as bool? ?? false,
      profilePictureFileId: json['profilePictureFileId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
    'role': role,
    'verified': verified,
    'profilePictureFileId': profilePictureFileId,
  };
}
