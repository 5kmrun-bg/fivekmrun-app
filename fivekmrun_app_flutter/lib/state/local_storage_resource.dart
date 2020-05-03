import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fivekmrun_flutter/constants.dart' as constants;

class LocalStorageResource extends ChangeNotifier {
  final String _keySubscribedForGeneral = "push_notifications_subscribed_general";

  Future<SharedPreferences> _storage = SharedPreferences.getInstance();

  Future<bool> get isSubscribedForGeneral async {
    final SharedPreferences storage = await _storage;
    return storage.getBool(this._keySubscribedForGeneral) ?? false;
  }

  set isSubscrubedForGeneral(bool value) {
    _storage.then((storage) => storage.setBool(this._keySubscribedForGeneral, value));
  }
}