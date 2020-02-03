import 'package:fivekmrun_flutter/donate/donate_page.dart';
import 'package:fivekmrun_flutter/past_events/event_results_page.dart';
import 'package:fivekmrun_flutter/past_events/past_events_page.dart';
import 'package:fivekmrun_flutter/future_events/future_events_page.dart';
import 'package:fivekmrun_flutter/profile.dart';
import 'package:fivekmrun_flutter/runs/run_details_page.dart';
import 'package:fivekmrun_flutter/runs/user_runs_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AppTab { profile, runs, futureEvents, pastEvents, donate }

Map<AppTab, GlobalKey<NavigatorState>> navigatorKeys = {
  AppTab.profile: GlobalKey<NavigatorState>(),
  AppTab.runs: GlobalKey<NavigatorState>(),
  AppTab.futureEvents: GlobalKey<NavigatorState>(),
  AppTab.pastEvents: GlobalKey<NavigatorState>(),
  AppTab.donate: GlobalKey<NavigatorState>(),
};

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class TabNavigationHelper {
  _HomeState _home;

  TabNavigationHelper(this._home);

  void selectTab(AppTab tab) {
    this._home.selectedIndex = tab.index;
  }

  pushToTab(AppTab tab, String routeName, {Object arguments}) {
    navigatorKeys[tab]
        .currentState
        .pushNamedAndRemoveUntil(routeName, (_) => true, arguments: arguments);
  }
}

class TabNavigator extends StatelessWidget {
  final Map<String, WidgetBuilder> routes;
  final GlobalKey<NavigatorState> navigatorKey;
  const TabNavigator(
      {Key key, @required this.routes, @required this.navigatorKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
            builder: routes[settings.name], settings: settings);
      },
    );
  }
}

class _HomeState extends State<Home> {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static final List<Widget> _widgetOptions = <Widget>[
    TabNavigator(
      navigatorKey: navigatorKeys[AppTab.profile],
      routes: {
        '/': (context) => ProfileDashboard(),
      },
    ),
    TabNavigator(
      navigatorKey: navigatorKeys[AppTab.runs],
      routes: {
        '/': (context) => UserRunsPage(),
        '/run-details': (context) => RunDetailsPage(),
      },
    ),
    TabNavigator(
      navigatorKey: navigatorKeys[AppTab.pastEvents],
      routes: {
        '/': (context) => PastEventsPage(),
        '/event-results': (context) => EventResultsPage(),
      },
    ),
    TabNavigator(
      navigatorKey: navigatorKeys[AppTab.futureEvents],
      routes: {
        '/': (context) => FutureEventsPage(),
      },
    ),
    TabNavigator(
      navigatorKey: navigatorKeys[AppTab.donate],
      routes: {
        '/': (context) => DonatePage(),
      },
    ),
  ];

  int _selectedIndex = 0;
  TabNavigationHelper _tabHelper;

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
    this._tabHelper = TabNavigationHelper(this);
  }

  void _onItemTapped(int index) {
    selectedIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => _tabHelper,
      child: Scaffold(
        body: Center(
          // child: _widgetOptions.elementAt(_selectedIndex),
          child: IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Профил'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_run),
              title: Text('Бягания'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              title: Text('Резултати'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              title: Text('Събития'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              title: Text('Дарения'),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
