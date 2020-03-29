import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:flutter/material.dart';
// To remove # at the end of redirect url when in web mode (not mobile)
// This is a web only package
// import 'dart:html' as html;

import 'package:strava_flutter/strava.dart';

// Used by example

import 'package:strava_flutter/Models/activity.dart';
import 'package:strava_flutter/Models/detailedAthlete.dart';

import '../secrets.dart';


Strava strava;

class OfflineChartPage extends StatelessWidget {
  const OfflineChartPage({Key key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strava Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StravaFlutterPage(title: 'strava_flutter demo'),
    );
  }
}

class StravaFlutterPage extends StatefulWidget {
  StravaFlutterPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StravaFlutterPageState createState() => _StravaFlutterPageState();
}

class _StravaFlutterPageState extends State<StravaFlutterPage> {
  List<SummaryActivity> stravaActivities;

  @override
  void initState() {
    setState(() {
      // html.window.history.pushState(null, "home", '/');
    });
    super.initState();
  }

  ///
  /// Example of dart code to use Strava API
  ///
  /// set isInDebug to true in strava init to see the debug info
  void example() async {

    bool isAuthOk = false;

    final strava = Strava(true, stravaSecret);
    final prompt = 'auto';

    isAuthOk = await strava.oauth(
        stravaClientId,
        'read_all,activity:read_all,profile:read_all',
        stravaSecret,
        prompt);

    if (isAuthOk) {
    
      // Type of expected answer:
      // {"id":25707617,"username":"patrick_ff","resource_state":3,"firstname":"Patrick","lastname":"FF",
      // "city":"Le Beausset","state":"Provence-Alpes-Côte d'Azur","country":"France","sex":null,"premium"
      DetailedAthlete _athlete = await strava.getLoggedInAthlete();
      if (_athlete.fault.statusCode != 200) {
        print(
            'Error in getloggedInAthlete ${_athlete.fault.statusCode}  ${_athlete.fault.message}');
      } else {
        print('getLoggedInAthlete ${_athlete.firstname}  ${_athlete.lastname}');
      }

      int before = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(0)).inSeconds;
      int after = DateTime.now().subtract(new Duration (days: 30)).difference(DateTime.fromMillisecondsSinceEpoch(0)).inSeconds;

      strava.getLoggedInAthleteActivities(before, after).then(
        (a) {
          print("BEFORE STATE " + a.length.toString());
          setState(() => this.stravaActivities = a);
          print("AFTER STATE " + a.length.toString());
        }
      ).catchError((e) => print(e));

    }
  }

  void deAuthorize() async {
    // need to get authorized before (valid token)
    final strava = Strava(
      true, // to get disply info in API
      stravaSecret, // Put your secret key in secret.dart file
    );
    var fault = await strava.deAuthorize();
  }

  @override
  void dispose() {
    strava.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(''),
            Text('Authentication'),
            Text('with other Apis'),
            RaisedButton(
              key: Key('OthersButton'),
              child: Text('strava_flutter'),
              onPressed: example,
            ),
            Text(' '),
            Text(''),
            Text(''),
            Text('Push this button'),
            Text(
              'to revoke/DeAuthorize Strava user',
            ),
            RaisedButton(
              key: Key('DeAuthorizeButton'),
              child: Text('DeAuthorize'),
              onPressed: deAuthorize,
            ),
            StravaActivityList(activities: this.stravaActivities)
          ],
        ),
      ),
    );
  }

}

class StravaActivityList extends StatelessWidget {
  const StravaActivityList({
    Key key,
    @required this.activities,
  }) : super(key: key);

  final List<SummaryActivity> activities;

  @override
  Widget build(BuildContext context) {
    if (activities == null) {
      return Text('chep');
    }

    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: activities.length,
      itemBuilder: _buildItemsForListView,
    );
  }
  
   ListTile _buildItemsForListView(BuildContext context, int index) {
      return ListTile(
        title: Text(activities[index].name), 
        subtitle: Text(activities[index].distance.toString()),
      );
  }
}