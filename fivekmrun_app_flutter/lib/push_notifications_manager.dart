import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fivekmrun_flutter/offline_chart/offline_chart_page.dart';
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
import 'package:flutter/material.dart';

class PushNotificationsManager {

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;
  static int _lastOnResumeCall = 0;
  static final PushNotificationsManager _instance = PushNotificationsManager._();
  static PushNotificationsManager getInstance() {
    return _instance;
  }
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init(BuildContext context) async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure(
          onResume: (Map<String, dynamic> msg) async {
              //(App in background)
              // From Notification bar when user click notification we get this event.
              // on this event navigate to a particular page.
              print("ON RESUME: " + msg.toString());
              // Assuming you will create classes to handle JSON data. :)
              final String title = msg['data']['title'];
              final String body = msg['data']['body'];
              final data = msg["data"];
              if (data != null) {
              final String routeName = data['routeName'];
              
                // if (data["routeName"] != null && data["routeName"] != "") {
                //   Navigator.pushNamed(context, routeName);
                // }
              }

              if (title != null && body != null) {
                await showNotification(context, title, body);
              }
          },
          onMessage: (Map<String, dynamic> msg) {
              final String title = msg['data']['title'];
              final String body = msg['data']['body'];
              // (App in foreground)
              // on this event add new message in notification collection and hightlight the count on bell icon.
              // Add notificaion add in local storage and show in a list.
              print("ON MESSAGE: " + msg.toString());
              showNotification(context, title, body);
        },
      );

      LocalStorageResource localStorageResource = new LocalStorageResource();
      localStorageResource.isSubscribedForGeneral.then((isSubscribed) { if (isSubscribed) this.subscribeTopic("general"); });

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");
      
      _initialized = true;
    }
  }

  Future showNotification(BuildContext context, String title, String body) async {
    //Dirty hack - FCM calls us twice
    if ((DateTime.now().microsecondsSinceEpoch - _lastOnResumeCall) > 1000000) {
      _lastOnResumeCall = DateTime.now().microsecondsSinceEpoch;
      await showDialog(context: context, builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          FlatButton(
            child: Text("OK"), 
            onPressed: () => Navigator.of(context).pop())
        ],));
    }
  }

  subscribeTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  unsubscribeTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}