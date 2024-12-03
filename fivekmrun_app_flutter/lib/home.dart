import 'package:after_layout/after_layout.dart';
import 'package:fivekmrun_flutter/app_rating_manager.dart';
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
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum AppTab { profile, runs, events, offlineChart, donate }

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

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

  _HomeState _home;

  TabNavigationHelper(this._home);

  void selectTab(AppTab tab) {
    this._home.selectedIndex = tab.index;
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
    print("HOME: start loading userId $userId");
    Provider.of<UserResource>(context, listen: false).currentUserId = userId;
    Provider.of<RunsResource>(context, listen: false).getByUserId(userId);
    Provider.of<AllFutureEventsResource>(context, listen: false).getAll();
    Provider.of<PastEventsResource>(context, listen: false).getAll();

    this._tabHelper = TabNavigationHelper(this);
    this._widgetOptions = <Widget>[
      TabNavigator(
        navigatorKey: this._tabHelper.navigatorKeys[AppTab.profile]!,
        routes: {
          '/': (context) => ProfileDashboard(),
        },
      ),
      TabNavigator(
        navigatorKey: this._tabHelper.navigatorKeys[AppTab.runs]!,
        routes: {
          '/': (context) => UserRunsPage(),
          '/run-details': (context) => RunDetailsPage(),
        },
      ),
      TabNavigator(
          navigatorKey: this._tabHelper.navigatorKeys[AppTab.offlineChart]!,
          routes: {
            '/': (context) => OfflineChartPage(),
            '/add': (context) => AddOfflineEntryPage(),
            '/details': (context) => OfflineChartDetailsPage(),
          }),
      TabNavigator(
        navigatorKey: this._tabHelper.navigatorKeys[AppTab.events]!,
        routes: {
          '/': (context) => EventsPage(),
          '/event-results': (context) => EventResultsPage(),
        },
      ),
      TabNavigator(
        navigatorKey: this._tabHelper.navigatorKeys[AppTab.donate]!,
        routes: {
          '/': (context) => DonatePage(),
        },
      ),
    ];
  }

  void _onItemTapped(int index) {
    selectedIndex = index;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    AppRatingManager(context);
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
              icon: Icon(Icons.person),
              label: AppLocalizations.of(context)!.home_label_profile
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_run),
              label: AppLocalizations.of(context)!.home_label_runs,
            ),
            BottomNavigationBarItem(
              icon: Icon(CustomIcons.award),
              label: 'Selfie',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: AppLocalizations.of(context)!.home_label_events,
            ),
            BottomNavigationBarItem(
              icon: Icon(CustomIcons.hand_holding_heart),
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
