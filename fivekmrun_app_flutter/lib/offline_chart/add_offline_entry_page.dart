import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/private/secrets.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/google_maps_service.dart';
import 'package:fivekmrun_flutter/state/offline_chart_resource.dart';
import 'package:fivekmrun_flutter/state/offline_chart_submission_model.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/strava_activity_model.dart';
import 'package:fivekmrun_flutter/state/strava_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:strava_flutter/Models/activity.dart';
import '../common/int_extensions.dart';
import '../common/double_extensions.dart';

final DateFormat dateFromat = DateFormat(Constants.DATE_FORMAT);

typedef void ActivityPressedCB(StravaSummaryRun activity);

class AddOfflineEntryPage extends StatefulWidget {
  AddOfflineEntryPage({Key key}) : super(key: key);

  @override
  _AddOfflineEntryPageState createState() => _AddOfflineEntryPageState();
}

class _AddOfflineEntryPageState extends State<AddOfflineEntryPage> {
  List<StravaSummaryRun> activities;
  StravaSummaryRun selectedActivity;
  bool isConnectedToStrava = false;
  bool isLoading = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    final strava = Provider.of<StravaResource>(this.context);
    final isConnectedToStrava = await strava.isAuthenticated();

    setState(() {
      this.isLoading = false;
      this.isConnectedToStrava = isConnectedToStrava;

      if (isConnectedToStrava) {
        loadActivities(strava);
      }
    });
  }

  void loadActivities(StravaResource strava) {
    setState(() {
      this.isLoading = true;
    });

    strava.getThisWeekActivities().then((loadedActivites) {
      this.setState(() {
        this.isLoading = false;
        if (loadedActivites != null) {
          this.activities = loadedActivites;
        } else {
          // Returning null means error while getting runs.
          this.activities = null;
          this.isConnectedToStrava = false;
        }
      });
    });
  }

  void submitOfflineEntry() async {
    if (this.selectedActivity == null) {
      return;
    }
    StravaSummaryRun runSummary = this.selectedActivity;

    DetailedActivity stravaActivity = this.selectedActivity.detailedActivity;
    UserResource userResource =
        Provider.of<UserResource>(context, listen: false);
    AuthenticationResource authResource =
        Provider.of<AuthenticationResource>(context, listen: false);
    OfflineChartResource offlineChartResource =
        Provider.of<OfflineChartResource>(context, listen: false);
    GoogleMapsService googleMapsService = GoogleMapsService();

    OfflineChartSubmissionModel model = new OfflineChartSubmissionModel(
      userId: userResource.currentUserId.toString(),
      elapsedTime: runSummary.fastestSplit.elapsedTime,
      distance: runSummary.fastestSplit.distance,
      startDate: DateTime.parse(stravaActivity.startDateLocal),
      mapPath: stravaActivity.map.polyline,
      startGeoLocation: stravaActivity.startLatlng,
      elevationGainedTotal: stravaActivity.totalElevationGain,
      elevationLow: stravaActivity.elevLow,
      elevationHigh: stravaActivity.elevHigh,
      totalDistance: stravaActivity.distance,
      totalElapsedTime: stravaActivity.elapsedTime,
      startLocation: await googleMapsService.getTownFromGeoLocation(
          stravaActivity.startLatitude, stravaActivity.startLongitude),
    );

    Crashlytics.instance.log("5kmRun Submission model: " + jsonEncode(model.toJson()));

    Map<String, dynamic> result;
    try {
      result = await offlineChartResource.submitEntry(
          model, authResource.getToken());
    } on Exception catch (e) {
      Crashlytics.instance.recordError(e, StackTrace.current);
      showDialog(
          context: context,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Сървърна грешка"),
              content: Text(
                  "Грешка при изпращане на данните. Моля, опитайте по-късно."),
              actions: <Widget>[
                FlatButton(
                    child: Text("OK"),
                    onPressed: () => Navigator.of(context).pop())
              ],
            );
          });
      return;
    }

    if (result["errors"] != null && result["errors"].length > 0) {
      if (result["errors"].contains("403")) {
        Crashlytics.instance.recordError(
            Exception("Unexpected invalid 5kmRun token"), StackTrace.current);
        final textStlyle = Theme.of(context).textTheme.subtitle;
        showDialog(
          context: context,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Невалидно потребителско име и парола"),
              content: RichText(
                text: TextSpan(
                  style: textStlyle,
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            'Влезте отново с вашите 5kmRun потребителско име и парола.'),
                  ],
                ),
              ),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Вход"),
                  onPressed: () async {
                    await authResource.logout();
                    Provider.of<UserResource>(context, listen: false).clear();
                    Provider.of<RunsResource>(context, listen: false).clear();

                    Navigator.of(context, rootNavigator: true)
                        .pushNamedAndRemoveUntil("/", (_) => false);
                  },
                ),
                new FlatButton(
                  child: new Text("Откажи"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        Crashlytics.instance.recordError(Exception(result["errors"].toString()), StackTrace.current);
                showDialog(
          context: context,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Грешка при изпращане на сървъра"),
              actions: <Widget>[
                FlatButton(
                    child: Text("OK"),
                    onPressed: () => Navigator.of(context).pop())
              ],
              content: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Грешка при изпращане на данните. Моля, опитайте по-късно.'),
                  ],
                ),
              ),
            );},
                );
      }
    }

    if (result["answer"]) {
      FirebaseAnalytics().logEvent(name: "submit_selfie_entry");
      Navigator.of(context).pushNamed("/");
    }
    else {
      Crashlytics.instance.recordError(Exception("Error from 5kmrun: " + result.toString()), StackTrace.current);
    }
  }

  void toggleActivity(StravaSummaryRun activity) {
    this.setState(() => {
          this.selectedActivity =
              this.selectedActivity == activity ? null : activity
        });
  }

  void triggerStravaAuth() {
    final strava = Provider.of<StravaResource>(this.context, listen: false);
    strava.authenticate().then(
          (success) => this.setState(() {
            this.isConnectedToStrava = success;
            this.loadActivities(strava);
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Участвай в класацията'),
      ),
      body: Center(
          child: this.isLoading
              ? CircularProgressIndicator()
              : this.isConnectedToStrava
                  ? this._buildList(context)
                  : this._buildStravaAuth(context)),
    );
  }

  Widget _buildStravaAuth(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 100,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "За да продължите - следвайте инструкциите за да свържете 5kmRun приложението с вашия Strava профил.\n \nМоля, използвайте Google Chrome при свързването и въведете директно Strava потребителско име и парола. В момента, свързване с други браузъри не сработва успешно.",
            style: Theme.of(context).textTheme.subtitle,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          height: 50,
        ),
        RaisedButton(
          color: Colors.transparent,
          child: Image(
            image: AssetImage('assets/btn_strava_connectwith_orange.png'),
          ),
          onPressed: this.triggerStravaAuth,
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: StravaActivityList(
              activities: this.activities,
              selectedActivity: this.selectedActivity,
              onActivityTap: toggleActivity),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: ProgressButton(
              defaultWidget: const Text("Участвай с избраното бягане"),
              progressWidget: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              type: ProgressButtonType.Raised,
              animate: true,
              onPressed: this.selectedActivity != null
                  ? () async {
                      await submitOfflineEntry();
                      return () {};
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class StravaActivityList extends StatelessWidget {
  final List<StravaSummaryRun> activities;
  final StravaSummaryRun selectedActivity;
  final ActivityPressedCB onActivityTap;

  const StravaActivityList(
      {Key key,
      @required this.activities,
      @required this.selectedActivity,
      @required this.onActivityTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activities == null) {
      return Center(child: CircularProgressIndicator());
    } else if (activities.length == 0) {
      return Text("Няма подходящи бягания");
    } else {
      return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: activities.length,
        itemBuilder: _buildItemsForListView,
      );
    }
  }

  Widget _buildItemsForListView(BuildContext context, int index) {
    final activity = activities[index];
    final date = DateTime.tryParse(activity.detailedActivity.startDate);
    final dateString = date != null ? dateFromat.format(date) : "n/a";
    final selectedColor = Colors.blueGrey.shade700;

    final totalTime = activity.detailedActivity.elapsedTime.parseSecondsToTimestamp();
    final totalDistance = activity.detailedActivity.distance.metersToKm();

    final fastestSplitTime = activity.fastestSplit.elapsedTime.parseSecondsToTimestamp();
    final fastestSplitDistance = activity.fastestSplit.distance.metersToKm();
    return Card(
      color: this.selectedActivity == activity
          ? selectedColor
          : Colors.transparent,
      child: ListTile(
        onTap: () => this.onActivityTap(activity),
        selected: this.selectedActivity == activity,
        title: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTileRow(text: activity.detailedActivity.name, icon: Icons.info),
                  ListTileRow(text: dateString, icon: Icons.calendar_today),
                  ListTileRow(
                      text: "$fastestSplitDistance / $totalDistance км",
                      icon: Icons.map),
                  ListTileRow(
                      text: "$fastestSplitTime / $totalTime",
                      icon: Icons.timer),
                ],
              ),
            ),
            Container(
              width: 140,
              child: Image.network(
                "https://maps.googleapis.com/maps/api/staticmap?size=140x140&zoom=13&path=weight:3%7Ccolor:blue%7Cenc:" +
                    activity.detailedActivity.map.polyline +
                    "&key=" +
                    googleMapsKey,
                fit: BoxFit.fitWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
