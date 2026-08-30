import 'package:after_layout/after_layout.dart';
import 'package:fivekmrun_flutter/app_rating_manager.dart';
import 'package:fivekmrun_flutter/common/refresh_helper.dart';
import 'package:fivekmrun_flutter/custom_icons.dart';
import 'package:fivekmrun_flutter/donate/donate_page.dart';
import 'package:fivekmrun_flutter/offline_chart/add_offline_entry_page.dart';
import 'package:fivekmrun_flutter/offline_chart/offline_chart_details_page.dart';
import 'package:fivekmrun_flutter/offline_chart/offline_chart_page.dart';
import 'package:fivekmrun_flutter/events/event_results_page.dart';
import 'package:fivekmrun_flutter/events/events_page.dart';
import 'package:fivekmrun_flutter/profile.dart';
import 'package:fivekmrun_flutter/runs/run_details_page.dart';
import 'package:fivekmrun_flutter/runs/user_runs_page.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/events_resource.dart';
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:fivekmrun_flutter/whats_new/whats_new_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';

enum AppTab { profile, runs, events, offlineChart, donate }

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class TabNavigationHelper {
  Map<AppTab, GlobalKey<NavigatorState>> navigatorKeys = {
    AppTab.profile: GlobalKey<NavigatorState>(),
    AppTab.runs: GlobalKey<NavigatorState>(),
    AppTab.events: GlobalKey<NavigatorState>(),
    AppTab.offlineChart: GlobalKey<NavigatorState>(),
    AppTab.donate: GlobalKey<NavigatorState>(),
  };

  final _HomeState _home;

  TabNavigationHelper(this._home);

  void selectTab(AppTab tab) {
    _home.selectedIndex = tab.index;
  }

  pushToTab(AppTab tab, String routeName, {Object? arguments}) {
    navigatorKeys[tab]!.currentState!.pushNamedAndRemoveUntil(
        routeName, ModalRoute.withName('/'),
        arguments: arguments);
  }
}

class TabNavigator extends StatelessWidget {
  final Map<String, WidgetBuilder> routes;
  final GlobalKey<NavigatorState> navigatorKey;
  const TabNavigator(
      {Key? key, @required required this.routes, required this.navigatorKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
            builder: routes[settings.name]!,
            settings: settings,
            fullscreenDialog: true); // disable back gesture on iOS
      },
    );
  }
}

class _HomeState extends State<Home> with AfterLayoutMixin<Home> {
  int _selectedIndex = 0;
  late TabNavigationHelper _tabHelper;
  late List<Widget> _widgetOptions;

  set selectedIndex(value) {
    if (value != _selectedIndex) {
      setState(() {
        _selectedIndex = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final userId =
        Provider.of<AuthenticationResource>(context, listen: false).getUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserResource>(context, listen: false).currentUserId = userId;
    });
    // Fire-and-forget: the resources notify their listeners when they land.
    // A failed fetch leaves the previous data in place, so there is nothing to
    // do here beyond keeping the error from going unhandled.
    reportOnFailure(
        Provider.of<RunsResource>(context, listen: false).getByUserId(userId),
        "runs");
    reportOnFailure(
        Provider.of<AllFutureEventsResource>(context, listen: false).getAll(),
        "future events");
    reportOnFailure(
        Provider.of<AllPastEventsResource>(context, listen: false).getAll(),
        "past events");

    _tabHelper = TabNavigationHelper(this);
    _widgetOptions = <Widget>[
      TabNavigator(
        navigatorKey: _tabHelper.navigatorKeys[AppTab.profile]!,
        routes: {
          '/': (context) => const ProfileDashboard(),
        },
      ),
      TabNavigator(
        navigatorKey: _tabHelper.navigatorKeys[AppTab.runs]!,
        routes: {
          '/': (context) => const UserRunsPage(),
          '/run-details': (context) => const RunDetailsPage(),
        },
      ),
      TabNavigator(
          navigatorKey: _tabHelper.navigatorKeys[AppTab.offlineChart]!,
          routes: {
            '/': (context) => OfflineChartPage(),
            '/add': (context) => const AddOfflineEntryPage(),
            '/details': (context) => const OfflineChartDetailsPage(),
          }),
      TabNavigator(
        navigatorKey: _tabHelper.navigatorKeys[AppTab.events]!,
        routes: {
          '/': (context) => const EventsPage(),
          '/event-results': (context) => const EventResultsPage(),
        },
      ),
      TabNavigator(
        navigatorKey: _tabHelper.navigatorKeys[AppTab.donate]!,
        routes: {
          '/': (context) => const DonatePage(),
        },
      ),
    ];
  }

  void _onItemTapped(int index) {
    selectedIndex = index;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _showWhatsNewThenRating(context);
  }

  /// The what's-new popup takes precedence on an update launch; if it shows,
  /// the rating dialog is skipped this launch rather than stacking behind
  /// it — `AppRatingManager` runs again naturally on a later launch.
  Future<void> _showWhatsNewThenRating(BuildContext context) async {
    final localStorage =
        Provider.of<LocalStorageResource>(context, listen: false);
    final manager = WhatsNewManager(localStorage: localStorage);
    final shown = await manager.maybeShowPopup(context);
    if (!mounted) return;
    if (!shown) {
      AppRatingManager(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var selectedColor = Theme.of(context).colorScheme.secondary;
    return Provider.value(
      value: _tabHelper,
      child: Scaffold(
        body: Center(
          child: IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          unselectedItemColor: Colors.white,
          selectedItemColor: selectedColor,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: AppLocalizations.of(context)!.home_label_profile),
            BottomNavigationBarItem(
              icon: const Icon(Icons.directions_run),
              label: AppLocalizations.of(context)!.home_label_runs,
            ),
            const BottomNavigationBarItem(
              icon: Icon(CustomIcons.award),
              label: 'Selfie',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today),
              label: AppLocalizations.of(context)!.home_label_events,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CustomIcons.hand_holding_heart),
              label: AppLocalizations.of(context)!.home_label_support,
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
