import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fivekmrun_flutter/state/profile_model.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fivekmrun_flutter/constants.dart' as constants;

/// Thrown by [AuthenticationResource.authenticate] /
/// [AuthenticationResource.authenticateWithUserId] when adding a genuinely
/// new profile would exceed [constants.maxProfiles].
class MaxProfilesReachedException implements Exception {}

/// Best-effort: telemetry must never become the reason profile management
/// fails, and must never require a real Firebase app in tests either.
void _logCrashlytics(String message) {
  try {
    FirebaseCrashlytics.instance.log(message);
  } catch (_) {}
}

void _setCrashlyticsUser(String? userId) {
  try {
    FirebaseCrashlytics.instance.setUserIdentifier(userId ?? "");
  } catch (_) {}
}

/// Holds every profile saved on this device and which one is active.
///
/// `getToken()`/`getUserId()`/`isLoggedIn()` describe the *active* profile —
/// every existing call site keeps working unchanged. `isLoggedIn()` in
/// particular has always meant "has a usable password-profile token", not
/// "has an active identity": an ID-only profile has never had a token, so
/// `getUserId()` (used to gate navigation/data-fetching) and `isLoggedIn()`
/// (used to gate token-only actions like Selfie submission) are deliberately
/// different questions.
class AuthenticationResource extends ChangeNotifier {
  List<Profile> _profiles = <Profile>[];
  int? _activeProfileId;

  List<Profile> get profiles => List.unmodifiable(_profiles);
  int? get activeProfileId => _activeProfileId;

  Profile? get activeProfile =>
      _profiles.firstWhereOrNull((p) => p.userId == _activeProfileId);

  Future<bool> authenticate(String username, String password,
      {bool makeActive = true}) async {
    _logCrashlytics("authenticate username - $username");

    HttpClient httpClient = HttpClient();
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse("https://5kmrun.bg/api/auth"));
    request.headers.set('content-type', 'application/x-www-form-urlencoded');
    request.write("userEmail=$username&userPassword=$password");

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    Map<String, dynamic> map = json.decode(reply);
    List<String> errors = List.from(map["errors"]);

    if (errors.isEmpty) {
      final token = map["answer"]["tkn"];
      final userId = map["answer"]["id"];

      if (token != null && token != "" && userId != null) {
        await _upsertProfile(
          Profile(
            userId: userId,
            type: ProfileType.password,
            token: token,
            tokenTimestamp: DateTime.now().millisecondsSinceEpoch,
            username: username,
          ),
          makeActive: makeActive,
        );

        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> authenticateWithUserId(int userId,
      {bool makeActive = true}) async {
    _logCrashlytics("authenticate userID - $userId");

    await _upsertProfile(
      Profile(userId: userId, type: ProfileType.idOnly),
      makeActive: makeActive,
    );
    return true;
  }

  /// Re-authenticates an already-saved profile with a password, refreshing
  /// its token and making it active. Works for a password profile whose
  /// token has expired (or was rejected) as much as for an ID-only profile
  /// that needs upgrading to a password one (e.g. to unlock a token-gated
  /// action like Selfie submission) — either way the profile is updated in
  /// place by user id, so every other saved profile is untouched. Returns
  /// false on a wrong password / failed request — the profile is left
  /// untouched so the prompt can be retried.
  ///
  /// The server authenticates by email, not by user id, so this needs the
  /// profile's email — normally its stored [Profile.username], but that's
  /// null for a profile migrated from the pre-multi-profile single-account
  /// keys (which never recorded it), or one that started ID-only. [username]
  /// lets the caller supply it in that case; once supplied it's saved on the
  /// profile so this only needs asking for it once.
  Future<bool> reauthenticateAndSwitch(int userId, String password,
      {String? username}) async {
    final existing = _profiles.firstWhereOrNull((p) => p.userId == userId);
    if (existing == null) return false;

    final email = username ?? existing.username;
    if (email == null) return false;

    HttpClient httpClient = HttpClient();
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse("https://5kmrun.bg/api/auth"));
    request.headers.set('content-type', 'application/x-www-form-urlencoded');
    request.write("userEmail=$email&userPassword=$password");

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    Map<String, dynamic> map = json.decode(reply);
    List<String> errors = List.from(map["errors"]);

    if (errors.isNotEmpty) return false;

    final token = map["answer"]["tkn"];
    final returnedUserId = map["answer"]["id"];
    if (token == null || token == "" || returnedUserId != userId) {
      return false;
    }

    await _upsertProfile(
      existing.copyWith(
        type: ProfileType.password,
        token: token,
        tokenTimestamp: DateTime.now().millisecondsSinceEpoch,
        username: email,
      ),
      makeActive: true,
    );
    return true;
  }

  /// Switches the active profile without touching its token. Returns false
  /// if [userId] has no saved profile.
  Future<bool> switchProfile(int userId) async {
    if (!_profiles.any((p) => p.userId == userId)) return false;

    _activeProfileId = userId;
    _setCrashlyticsUser(userId.toString());
    await _persistActiveProfileId();
    notifyListeners();
    return true;
  }

  /// Removes a saved profile (clearing its token locally — no server-side
  /// invalidation call, per #184's grooming). If it was the active profile,
  /// falls back to another saved profile, or to no active profile (login
  /// screen) if none remain. Returns the new active profile id, or null.
  Future<int?> removeProfile(int userId) async {
    final wasActive = _activeProfileId == userId;
    _profiles.removeWhere((p) => p.userId == userId);
    await _persistProfiles();

    if (wasActive) {
      _activeProfileId =
          _profiles.isNotEmpty ? _profiles.first.userId : null;
      _setCrashlyticsUser(_activeProfileId?.toString());
      await _persistActiveProfileId();
    }

    notifyListeners();
    return _activeProfileId;
  }

  String? getToken() {
    final profile = activeProfile;
    if (profile == null || profile.isTokenExpired) return null;
    return profile.token;
  }

  int? getUserId() {
    return activeProfile?.userId;
  }

  bool isLoggedIn() {
    return getToken() != null;
  }

  /// Clears every saved profile — used by the "sign out of this device"
  /// action (Settings), as distinct from [removeProfile] which removes a
  /// single profile from the switcher.
  Future<void> logout() async {
    _logCrashlytics("logout() started");
    _profiles = <Profile>[];
    _activeProfileId = null;
    _setCrashlyticsUser(null);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(constants.key_profiles);
    await prefs.remove(constants.key_activeProfileId);
    // Pre-multi-profile keys — removed too so a stale copy can't resurrect
    // itself on the next migration check.
    await prefs.remove(constants.key_userId);
    await prefs.remove(constants.key_token);
    await prefs.remove(constants.key_tokenTimestamp);

    notifyListeners();
    _logCrashlytics("logout() completed");
  }

  /// Updates the profile's cached display fields (name/avatar), used once
  /// [UserResource] resolves the full profile for a profile that was added
  /// or migrated with only an id.
  Future<void> updateProfileDisplay(int userId,
      {required String name, required String avatarUrl}) async {
    final index = _profiles.indexWhere((p) => p.userId == userId);
    if (index == -1) return;
    if (_profiles[index].name == name &&
        _profiles[index].avatarUrl == avatarUrl) {
      return;
    }

    _profiles[index] =
        _profiles[index].copyWith(name: name, avatarUrl: avatarUrl);
    await _persistProfiles();
    notifyListeners();
  }

  Future<void> _upsertProfile(Profile profile,
      {required bool makeActive}) async {
    final index = _profiles.indexWhere((p) => p.userId == profile.userId);
    if (index != -1) {
      // Re-adding an existing profile refreshes it (e.g. an ID-only profile
      // upgraded to a password one, or a token refresh) instead of
      // duplicating it — the cap below only applies to genuinely new ids.
      _profiles[index] = profile.copyWith(
        username: profile.username ?? _profiles[index].username,
        name: _profiles[index].name,
        avatarUrl: _profiles[index].avatarUrl,
      );
    } else {
      if (_profiles.length >= constants.maxProfiles) {
        throw MaxProfilesReachedException();
      }
      _profiles.add(profile);
    }

    await _persistProfiles();

    if (makeActive) {
      _activeProfileId = profile.userId;
      _setCrashlyticsUser(profile.userId.toString());
      await _persistActiveProfileId();
    }

    notifyListeners();
  }

  Future<void> _persistProfiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(constants.key_profiles,
        jsonEncode(_profiles.map((p) => p.toJson()).toList()));
  }

  Future<void> _persistActiveProfileId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_activeProfileId != null) {
      await prefs.setInt(constants.key_activeProfileId, _activeProfileId!);
    } else {
      await prefs.remove(constants.key_activeProfileId);
    }
  }

  Future<void> loadFromLocalStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final profilesJson = prefs.getString(constants.key_profiles);
    if (profilesJson != null) {
      final List<dynamic> decoded = jsonDecode(profilesJson);
      _profiles = decoded
          .map((e) => Profile.fromJson(e as Map<String, dynamic>))
          .toList();
      _activeProfileId = prefs.getInt(constants.key_activeProfileId);
    } else {
      await _migrateSingleAccount(prefs);
    }

    _setCrashlyticsUser(_activeProfileId?.toString());
  }

  /// One-time migration for a device that predates multi-profile support:
  /// wraps the old single `{userId, token, timestamp}` keys into a one-item
  /// profile list, so an existing user is never signed out by the upgrade.
  Future<void> _migrateSingleAccount(SharedPreferences prefs) async {
    final userId = prefs.getInt(constants.key_userId);
    if (userId == null) return;

    final token = prefs.getString(constants.key_token);
    final tokenTimestamp = prefs.getInt(constants.key_tokenTimestamp);

    _profiles = <Profile>[
      Profile(
        userId: userId,
        type: token != null ? ProfileType.password : ProfileType.idOnly,
        token: token,
        tokenTimestamp: tokenTimestamp,
      ),
    ];
    _activeProfileId = userId;

    await _persistProfiles();
    await _persistActiveProfileId();
  }
}
