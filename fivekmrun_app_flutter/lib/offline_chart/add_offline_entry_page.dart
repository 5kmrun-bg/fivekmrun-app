import 'package:fivekmrun_flutter/private/secrets.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/offline_chart_resource.dart';
import 'package:fivekmrun_flutter/state/offline_chart_submission_model.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strava_flutter/Models/activity.dart';
import 'package:strava_flutter/strava.dart';
import '../common/int_extensions.dart';
import '../common/double_extensions.dart';

// TODO: Wrap this as a resource
Strava strava;

class AddOfflineEntryPage extends StatefulWidget {
  AddOfflineEntryPage({Key key}) : super(key: key);

  @override
  _AddOfflineEntryPageState createState() => _AddOfflineEntryPageState();
}

class _AddOfflineEntryPageState extends State<AddOfflineEntryPage> {
  List<SummaryActivity> stravaActivities;

  void initStrava() async {
    strava = Strava(true, stravaSecret);

    bool isAuthOk = await strava.oauth(stravaClientId,
        'read_all,activity:read_all,profile:read_all', stravaSecret, 'auto');

    if (isAuthOk) {}
  }

  void loadActivities() async {
    if (strava == null) {
      strava = Strava(true, stravaSecret);
    }

    bool isAuthOk = await strava.oauth(stravaClientId,
        'read_all,activity:read_all,profile:read_all', stravaSecret, 'auto');
    if (isAuthOk) {
      var stravaRuns = await getActivities(strava);
      this.setState(() => this.stravaActivities = stravaRuns);
    }
  }

  Future<List<SummaryActivity>> getActivities(Strava stravaApi) async {
    int before = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(0))
        .inSeconds;
    int after = DateTime.now()
        .subtract(new Duration(days: 7))
        .difference(DateTime.fromMillisecondsSinceEpoch(0))
        .inSeconds;

    var activities = await strava.getLoggedInAthleteActivities(before, after);

    var runActivites =
        activities.where((a) => a.type == ActivityType.Run).toList();

    return runActivites;
  }

  @override
  void dispose() {
    if (strava != null) {
      strava.dispose();
      strava = null;
    }

    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Участвай в класацията'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Image(
                image:
                    AssetImage('assets/btn_strava_connectwith_orange@2x.png'),
              ),
              onPressed: loadActivities,
            ),
            RaisedButton(
                onPressed: submitOfflineEntry,
                child: Text("Submit offline entry")),
            Expanded(
              child: StravaActivityList(activities: this.stravaActivities),
            )
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
      return Text('Зареждане ...');
    }

    return ListView.builder(
      scrollDirection: Axis.vertical,
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
