import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fivekmrun_flutter/barcode_page.dart';
import 'package:fivekmrun_flutter/donate/donate_page.dart';
import 'package:fivekmrun_flutter/home.dart';
import 'package:fivekmrun_flutter/login/helpers.dart';
import 'package:fivekmrun_flutter/login/login.dart';
import 'package:fivekmrun_flutter/login/login_preview.dart';
import 'package:fivekmrun_flutter/manage_profiles_page.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/state/locale_provider.dart';
import 'package:provider/provider.dart';

final userRes = UserResource();
final authRes = AuthenticationResource();

const appAccentColor = Color.fromRGBO(218, 3, 56, 1.0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Opt in explicitly instead of relying on Android 15+ enforcement. Icons
  // are always light because the app is permanently in dark theme (see
  // themeMode: ThemeMode.dark below) regardless of the device setting.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

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
  static final navKey = GlobalKey<NavigatorState>();

  const MyApp(this._initialRoute, {super.key});
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
        ChangeNotifierProvider(create: (_) => AllPastEventsResource()),
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
            // `locale` is null for the first frames, while LocaleProvider
            // reads the saved preference. Leaving it null there would let
            // Flutter resolve against the *device* locale, so an English
            // phone would flash an English UI before settling on the saved
            // choice — hence the explicit default.
            locale: localeProvider.locale ?? defaultLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Kept in sync with the .arb files by the generator.
            supportedLocales: AppLocalizations.supportedLocales,
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData(
              useMaterial3: false,
              dividerColor: Colors.black12,
              textTheme: const TextTheme(
                titleSmall:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
                  backgroundColor: const Color.fromRGBO(66, 66, 66, 1),
                  iconTheme: const IconThemeData(color: Colors.white),
                  titleTextStyle: Theme.of(context)
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
              '/': (_) => const Login(),
              'add-profile': (_) => const Login(addingProfile: true),
              'manage-profiles': (_) => const ManageProfilesPage(),
              'loginPreview': (_) => const LoginPreview(),
              'home': (_) => const Home(),
              'barcode': (_) => const BarcodePage(),
              'settings': (_) => const SettingsPage(),
              'donation': (_) => const DonatePage(),
            },
          );
        },
      ),
    );
  }
}
