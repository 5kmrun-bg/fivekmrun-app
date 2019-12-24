import 'package:fivekmrun_flutter/home.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login.dart';
import 'loginPreview.dart';

final appTheme = ThemeData(
  primarySwatch: Colors.deepOrange,
  brightness: Brightness.dark,
  backgroundColor: Colors.black,
  accentColor: Colors.deepOrangeAccent,
  accentIconTheme: IconThemeData(color: Colors.black),
  dividerColor: Colors.black12,
  textTheme: TextTheme(
    body2: TextStyle(fontWeight: FontWeight.bold),
  ),
);

final userRes = UserResource();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var userId = await userRes.presistedId();
  String initialRoute = "/";
  if (userId != 0 && userId != null) {
    print("userID ${userId.toString()}");
    userRes.load(userId);
    initialRoute = "/home";
  }

  runApp(MyApp(initialRoute));
}

class MyApp extends StatelessWidget {
  final String _initialRoute;

  MyApp(this._initialRoute);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => userRes,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: appTheme,
        initialRoute: _initialRoute,
        routes: {
          '/': (context) => Login(),
          '/loginPreview': (context) => LoginPreview(),
          '/home': (context) => Home(),
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
