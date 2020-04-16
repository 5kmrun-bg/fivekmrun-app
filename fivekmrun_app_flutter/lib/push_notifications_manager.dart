import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';

class PushNotificationsManager {

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();
  static PushNotificationsManager getInstance() {
    return _instance;
  }
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure();

      LocalStorageResource localStorageResource = new LocalStorageResource();
      localStorageResource.isSubscribedForGeneral.then((isSubscribed) => this.subscribeTopic("general"));

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");
      
      _initialized = true;
    }
  }

  subscribeTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  unsubscribeTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}