import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageResource extends ChangeNotifier {
  final String _keySubscribedForGeneral =
      "push_notifications_subscribed_general";

  final Future<SharedPreferences> _storage = SharedPreferences.getInstance();

  Future<bool> get isSubscribedForGeneral async {
    final SharedPreferences storage = await _storage;
    return storage.getBool(_keySubscribedForGeneral) ?? false;
  }

  set isSubscrubedForGeneral(bool value) {
    _storage.then(
        (storage) => storage.setBool(_keySubscribedForGeneral, value));
  }

  /// Null on a fresh install: nothing has been acknowledged yet.
  Future<String?> get lastSeenWhatsNewVersion async {
    final SharedPreferences storage = await _storage;
    return storage.getString(constants.key_lastSeenWhatsNewVersion);
  }

  /// Awaited (unlike [isSubscrubedForGeneral]'s fire-and-forget setter) so
  /// callers can rely on the write landing before deciding whether to show
  /// the what's-new popup again on a following launch.
  Future<void> setLastSeenWhatsNewVersion(String version) async {
    final storage = await _storage;
    await storage.setString(constants.key_lastSeenWhatsNewVersion, version);
  }
}
