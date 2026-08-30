import 'package:fivekmrun_flutter/constants.dart' as constants;

/// Mirrors the two existing login paths in [AuthenticationResource].
enum ProfileType { password, idOnly }

/// A single saved account on this device. Multiple profiles let a user (most
/// commonly a parent managing their kid's account too) switch between
/// accounts without signing out.
class Profile {
  final int userId;
  final ProfileType type;

  /// Null for an [ProfileType.idOnly] profile — no password was ever
  /// provided, so there is nothing to authenticate token-gated actions with.
  final String? token;

  /// Epoch milliseconds; null for an [ProfileType.idOnly] profile.
  final int? tokenTimestamp;

  /// The email a password profile logs in with. Never a secret by itself,
  /// but stored so an expired-token re-auth only needs to prompt for the
  /// password — the server authenticates by email, not by user id, so
  /// without this there would be nothing to re-authenticate with. Null for
  /// an [ProfileType.idOnly] profile, and for a profile migrated from the
  /// pre-multi-profile single-account keys (which never recorded it either).
  final String? username;

  /// Cached for the switcher UI so it doesn't need a network round trip to
  /// list saved profiles. Refreshed opportunistically once [UserResource]
  /// loads the full profile.
  final String name;
  final String avatarUrl;

  const Profile({
    required this.userId,
    required this.type,
    this.token,
    this.tokenTimestamp,
    this.username,
    this.name = "",
    this.avatarUrl = "",
  });

  /// An ID-only profile has nothing to expire. A password profile with no
  /// stored token/timestamp counts as expired — there is nothing valid to
  /// use.
  bool get isTokenExpired {
    if (type == ProfileType.idOnly) return false;
    if (token == null || token!.isEmpty || tokenTimestamp == null) {
      return true;
    }

    final created = DateTime.fromMillisecondsSinceEpoch(tokenTimestamp!);
    final expiresAt = created.add(const Duration(days: constants.tokenExpiryDays));
    return !expiresAt.isAfter(DateTime.now());
  }

  Profile copyWith({
    ProfileType? type,
    String? token,
    int? tokenTimestamp,
    String? username,
    String? name,
    String? avatarUrl,
  }) {
    return Profile(
      userId: userId,
      type: type ?? this.type,
      token: token ?? this.token,
      tokenTimestamp: tokenTimestamp ?? this.tokenTimestamp,
      username: username ?? this.username,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'type': type.name,
        'token': token,
        'tokenTimestamp': tokenTimestamp,
        'username': username,
        'name': name,
        'avatarUrl': avatarUrl,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        userId: json['userId'] as int,
        type: ProfileType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => ProfileType.idOnly,
        ),
        token: json['token'] as String?,
        tokenTimestamp: json['tokenTimestamp'] as int?,
        username: json['username'] as String?,
        name: json['name'] as String? ?? "",
        avatarUrl: json['avatarUrl'] as String? ?? "",
      );
}
