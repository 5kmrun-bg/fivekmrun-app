import 'package:after_layout/after_layout.dart';
import 'package:fivekmrun_flutter/app_rating_manager.dart';
import 'package:fivekmrun_flutter/custom_icons.dart';
import 'package:fivekmrun_flutter/offline_chart/add_offline_entry_page.dart';
import 'package:fivekmrun_flutter/offline_chart/offline_chart_details_page.dart';
import 'package:fivekmrun_flutter/offline_chart/offline_chart_page.dart';
import 'package:fivekmrun_flutter/past_events/event_results_page.dart';
import 'package:fivekmrun_flutter/past_events/past_events_page.dart';
import 'package:fivekmrun_flutter/future_events/future_events_page.dart';
import 'package:fivekmrun_flutter/profile.dart';
import 'package:fivekmrun_flutter/push_notifications_manager.dart';
import 'package:fivekmrun_flutter/runs/run_details_page.dart';
import 'package:fivekmrun_flutter/runs/user_runs_page.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/events_resource.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AppTab { profile, runs, futureEvents, pastEvents, offlineChart }

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class TabNavigationHelper {
  Map<AppTab, GlobalKey<NavigatorState>> navigatorKeys = {
    AppTab.profile: GlobalKey<NavigatorState>(),
    AppTab.runs: GlobalKey<NavigatorState>(),
    AppTab.futureEvents: GlobalKey<NavigatorState>(),
    AppTab.pastEvents: GlobalKey<NavigatorState>(),
    AppTab.offlineChart: GlobalKey<NavigatorState>()
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
  TabNavigationHelper? _tabHelper;
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
    //PushNotificationsManager().init(context);

    super.initState();

    final userId =
        Provider.of<AuthenticationResource>(context, listen: false).getUserId();
    print("HOME: start loading userId $userId");
    Provider.of<UserResource>(context, listen: false).currentUserId = userId;
    Provider.of<RunsResource>(context, listen: false).getByUserId(userId);
    Provider.of<FutureEventsResource>(context, listen: false).getAll();
    Provider.of<PastEventsResource>(context, listen: false).getAll();

    this._tabHelper = TabNavigationHelper(this);
    this._widgetOptions = <Widget>[
      TabNavigator(
        navigatorKey: this._tabHelper!.navigatorKeys[AppTab.profile]!,
        routes: {
          '/': (context) => ProfileDashboard(),
        },
      ),
      TabNavigator(
        navigatorKey: this._tabHelper!.navigatorKeys[AppTab.runs]!,
        routes: {
          '/': (context) => UserRunsPage(),
          '/run-details': (context) => RunDetailsPage(),
        },
      ),
      TabNavigator(
          navigatorKey: this._tabHelper!.navigatorKeys[AppTab.offlineChart]!,
          routes: {
            '/': (context) => OfflineChartPage(),
            '/add': (context) => AddOfflineEntryPage(),
            '/details': (context) => OfflineChartDetailsPage(),
          }),
      TabNavigator(
        navigatorKey: this._tabHelper!.navigatorKeys[AppTab.pastEvents]!,
        routes: {
          '/': (context) => PastEventsPage(),
          '/event-results': (context) => EventResultsPage(),
        },
      ),
      TabNavigator(
        navigatorKey: this._tabHelper!.navigatorKeys[AppTab.futureEvents]!,
        routes: {
          '/': (context) => FutureEventsPage(),
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
    var selectedColor = Theme.of(context).accentColor;
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
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профил',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_run),
              label: 'Бягания',
            ),
            BottomNavigationBarItem(
              icon: Icon(CustomIcons.award),
              label: 'Selfie',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              label: 'Резултати',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Събития',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
