import 'package:firebase_core/firebase_core.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/state/locale_provider.dart';
import 'package:provider/provider.dart';

final userRes = UserResource();
final authRes = AuthenticationResource();

final appAccentColor = Color.fromRGBO(218, 3, 56, 1.0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Pass all uncaught errors to Crashlytics.
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    // Forward to original handler.
    originalOnError!(errorDetails);
  };

  await authRes.loadFromLocalStore();
  String initialRoute = "/";

  final userId = authRes.getUserId();
  if (authRes.getUserId() != null) {
    FirebaseCrashlytics.instance.setUserIdentifier(userId.toString());
    userRes.currentUserId = userId;
    initialRoute = "home";
  }

  runApp(MyApp(initialRoute));
}

class MyApp extends StatelessWidget {
  final String _initialRoute;
  static final navKey = new GlobalKey<NavigatorState>();

  MyApp(this._initialRoute);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    PushNotificationsManager().init(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authRes),
        ChangeNotifierProvider(create: (_) => userRes),
        ChangeNotifierProvider(create: (_) => RunsResource()),
        ChangeNotifierProvider(create: (_) => AllFutureEventsResource()),
        ChangeNotifierProvider(create: (_) => PastEventsResource()),
        ChangeNotifierProvider(create: (_) => OfflineChartResource()),
        ChangeNotifierProvider(create: (_) => LocalStorageResource()),
        ChangeNotifierProvider(create: (_) => StravaResource()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            navigatorKey: MyApp.navKey,
            debugShowCheckedModeBanner: false,
            title: '5kmRun.bg',
            locale: localeProvider.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en'),
              Locale('bg'),
            ],
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData(
              useMaterial3: false,
              dividerColor: Colors.black12,
              textTheme: TextTheme(
                titleSmall: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold),
                bodyLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                bodyMedium: TextStyle(fontSize: 10),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                        return Colors.white;
                      }))),
              textButtonTheme: TextButtonThemeData(style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                      return Colors.white;
                    }),
              )),
              appBarTheme: AppBarTheme(
                  backgroundColor: Color.fromRGBO(66, 66, 66, 1),
                  iconTheme: IconThemeData(color: Colors.white),
                  titleTextStyle: Theme
                      .of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white)),
              colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: getColor(appAccentColor),
                  backgroundColor: Colors.black,
                  accentColor: appAccentColor,
                  errorColor: Colors.red,
                  brightness: Brightness.dark),
            ),
            initialRoute: _initialRoute,
            routes: {
              '/': (_) => Login(),
              'loginPreview': (_) => LoginPreview(),
              'home': (_) => Home(),
              'barcode': (_) => BarcodePage(),
              'settings': (_) => SettingsPage(),
              'donation': (_) => DonatePage(),
            },
          );
        },
      ),
    );
  }
}