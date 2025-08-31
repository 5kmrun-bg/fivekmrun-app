import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fivekmrun_flutter/main.dart';
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_app_badger/flutter_app_badger.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;
  static int _lastOnResumeCall = 0;
  static final PushNotificationsManager _instance =
      PushNotificationsManager._();
  static PushNotificationsManager getInstance() {
    return _instance;
  }

  bool _initialized = false;

  Future<void> init(BuildContext context) async {
    // TODO: Enable FlutterAppBadger
    // FlutterAppBadger.removeBadge();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (!_initialized) {
      // For iOS request permission first.
      NotificationSettings setting = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
        final String title = msg.notification?.title ?? "";
        final String body = msg.notification?.body ?? "";
        // (App in foreground)
        // on this event add new message in notification collection and hightlight the count on bell icon.
        // Add notificaion add in local storage and show in a list.
        print("ON MESSAGE: ");
        inspect(msg);

        showNotification(MyApp.navKey.currentState?.overlay?.context ?? context,
            title, body);
      });

      // messaging.configure(
      //   onResume: (Map<String, dynamic> msg) async {
      //     //(App in background)
      //     // From Notification bar when user click notification we get this event.
      //     // on this event navigate to a particular page.
      //     print("ON RESUME: " + msg.toString());
      //     // Assuming you will create classes to handle JSON data. :)
      //     final String title = msg['data']['title'];
      //     final String body = msg['data']['body'];
      //     final data = msg["data"];
      //     if (data != null) {
      //       final String routeName = data['routeName'];

      //       // if (data["routeName"] != null && data["routeName"] != "") {
      //       //   Navigator.pushNamed(context, routeName);
      //       // }
      //     }

      //     if (title != null && body != null) {
      //       await showNotification(context, title, body);
      //     }
      //   },
      //   onMessage: (Map<String, dynamic> msg) {
      //     final String title = msg['data']['title'];
      //     final String body = msg['data']['body'];
      //     // (App in foreground)
      //     // on this event add new message in notification collection and hightlight the count on bell icon.
      //     // Add notificaion add in local storage and show in a list.
      //     print("ON MESSAGE: " + msg.toString());
      //     showNotification(context, title, body);
      //   },
      // );

      LocalStorageResource localStorageResource = new LocalStorageResource();
      localStorageResource.isSubscribedForGeneral.then((isSubscribed) {
        if (isSubscribed) this.subscribeTopic("general");
      });

      // For testing purposes print the Firebase Messaging token
      // String? token = await FirebaseMessaging.instance.getToken();
      // print("FirebaseMessaging token: $token");

      _initialized = true;
    }
  }

  Future<void> showNotification(
      BuildContext context, String title, String body) async {
    //Dirty hack - FCM calls us twice
    // if ((DateTime.now().microsecondsSinceEpoch - _lastOnResumeCall) > 1000000) {
    //   _lastOnResumeCall = DateTime.now().microsecondsSinceEpoch;
    switch (await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                TextButton(
                    child: Text("OK"),
                    onPressed: () => Navigator.of(context).pop())
              ],
            ))) {
      case true:
        break;
      case false:
        break;
    }
  }
  // }

  subscribeTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  unsubscribeTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}
