import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/offline_chart_resource.dart';
import 'package:fivekmrun_flutter/state/offline_chart_submission_model.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:strava_flutter/strava.dart';
import 'package:strava_flutter/Models/activity.dart';
import '../private/secrets.dart';
import '../common/int_extensions.dart';
import '../common/double_extensions.dart';

Strava strava;

class OfflineChartPage extends StatelessWidget {
  const OfflineChartPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StravaFlutterPage(title: 'Седмична офлайн класация');
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
    setState(() {});
    super.initState();
  }

  void example() async {
    bool isAuthOk = false;

    strava = Strava(true, stravaSecret);
    final prompt = 'auto';

    isAuthOk = await strava.oauth(stravaClientId,
        'read_all,activity:read_all,profile:read_all', stravaSecret, prompt);

    if (isAuthOk) {
      int before = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(0))
          .inSeconds;
      int after = DateTime.now()
          .subtract(new Duration(days: 90))
          .difference(DateTime.fromMillisecondsSinceEpoch(0))
          .inSeconds;

      strava.getLoggedInAthleteActivities(before, after).then((a) {
        print("BEFORE STATE " + a.length.toString());
        setState(() => this.stravaActivities =
            a.where((i) => i.type == ActivityType.Run).toList());
        print("AFTER STATE " + a.length.toString());
      }).catchError((e) => print(e));
    }
  }

  @override
  void dispose() {
    if (strava != null) {
      strava.dispose();
      strava = null;
    }

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
            RaisedButton(
                key: Key("SubmitOfflineEntry"),
                onPressed: submitOfflineEntry,
                child: Text("Submit offline entry")),
            Text(''),
            Text('Authentication'),
            Text('with other Apis'),
            RaisedButton(
              key: Key('OthersButton'),
              child: Image(
                  image: AssetImage(
                      'assets/btn_strava_connectwith_orange@2x.png')),
              onPressed: example,
            ),
            StravaActivityList(activities: this.stravaActivities)
          ],
        ),
      ),
    );
  }

  submitOfflineEntry() {
    SummaryActivity stravaActivity = this.stravaActivities[0];
    UserResource userResource =
        Provider.of<UserResource>(context, listen: false);
    AuthenticationResource authResource =
        Provider.of<AuthenticationResource>(context, listen: false);
    OfflineChartResource offlineChartResource =
        Provider.of<OfflineChartResource>(context, listen: false);

    OfflineChartSubmissionModel model = new OfflineChartSubmissionModel(
      userId: userResource.currentUserId.toString(),
      elapsedTime: stravaActivity.elapsedTime,
      distance: stravaActivity.distance,
      startDate: DateTime.now(),
      mapPath: "", //stravaActivity.map.polyline,
      startLocation: [0.1, 0.2], //stravaActivity.startLatlng,
    );

    offlineChartResource.submitEntry(model, authResource.getToken());
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
      subtitle: StravaResultTile(activity: activities[index]),
    );
  }
}

class StravaResultTile extends StatelessWidget {
  const StravaResultTile({Key key, @required this.activity}) : super(key: key);

  final SummaryActivity activity;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text('Дистанция'),
              Text(this.activity.distance.parseMetersToKilometers())
            ],
          ),
          Column(
            children: <Widget>[
              Text('Време'),
              Text(this.activity.elapsedTime.parseSecondsToTimestamp())
            ],
          ),
        ],
      ),
      Row(
        children: <Widget>[
          FutureBuilder<DetailedActivity>(
              future: strava.getActivityById(this.activity.id.toString()),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.network(
                      "https://maps.googleapis.com/maps/api/staticmap?size=200x200&zoom=15&path=weight:3%7Ccolor:blue%7Cenc:" +
                          snapshot.data.map.polyline +
                          "&key=" +
                          googleMapsKey);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else {
                  return CircularProgressIndicator();
                }
              })
        ],
      )
    ]);
  }
}
