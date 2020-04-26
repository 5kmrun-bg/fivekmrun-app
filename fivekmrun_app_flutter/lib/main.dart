import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fivekmrun_flutter/barcode_page.dart';
import 'package:fivekmrun_flutter/donate/donate_page.dart';
import 'package:fivekmrun_flutter/home.dart';
import 'package:fivekmrun_flutter/login/helpers.dart';
import 'package:fivekmrun_flutter/login/login.dart';
import 'package:fivekmrun_flutter/login/loginPreview.dart';
import 'package:fivekmrun_flutter/push_notifications_manager.dart';
import 'package:fivekmrun_flutter/settings_page.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/events_resource.dart';
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
import 'package:fivekmrun_flutter/state/offline_chart_resource.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/strava_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final userRes = UserResource();
final authRes = AuthenticationResource();

final appAccentColor = Color.fromRGBO(252, 24, 81, 1.0);

void main() async {
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  WidgetsFlutterBinding.ensureInitialized();
  await authRes.loadFromLocalStore();
  String initialRoute = "/";

  final userId = authRes.getUserId();
  if (authRes.getUserId() != null) {
    Crashlytics.instance.setUserIdentifier(userId.toString());
    userRes.currentUserId = userId;
    initialRoute = "/home";
  }

  runZoned(() {
    runApp(MyApp(initialRoute));
  }, onError: Crashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  final String _initialRoute;

  MyApp(this._initialRoute);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    PushNotificationsManager().init();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authRes),
        ChangeNotifierProvider(create: (_) => userRes),
        ChangeNotifierProvider(create: (_) => RunsResource()),
        ChangeNotifierProvider(create: (_) => FutureEventsResource()),
        ChangeNotifierProvider(create: (_) => PastEventsResource()),
        ChangeNotifierProvider(create: (_) => OfflineChartResource()),
        ChangeNotifierProvider(create: (_) => LocalStorageResource()),
        ChangeNotifierProvider(create: (_) => StravaResource()),
      ],
      child: MaterialApp(
        title: '5kmRun.bg',
        theme: ThemeData(
          primarySwatch: getColor(appAccentColor),
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          accentColor: appAccentColor,
          accentIconTheme: IconThemeData(color: Colors.black),
          dividerColor: Colors.black12,
          textTheme: TextTheme(
            subhead: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            body1: TextStyle(fontSize: 10),
            body2: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
          errorColor: Colors.red,
        ),
        initialRoute: _initialRoute,
        routes: {
          '/': (_) => Login(),
          '/loginPreview': (_) => LoginPreview(),
          '/home': (_) => Home(),
          '/barcode': (_) => BarcodePage(),
          '/settings': (_) => SettingsPage(),
          '/donation': (_) => DonatePage(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Login(),
          ],
        ),
      ),
    );
  }
}
