import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/private/secrets.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/offline_chart_resource.dart';
import 'package:fivekmrun_flutter/state/offline_chart_submission_model.dart';
import 'package:fivekmrun_flutter/state/strava_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:strava_flutter/Models/activity.dart';
import '../common/int_extensions.dart';
import '../common/double_extensions.dart';

final DateFormat dateFromat = DateFormat(Constants.DATE_FORMAT);

typedef void ActivityPressedCB(DetailedActivity activity);

class AddOfflineEntryPage extends StatefulWidget {
  AddOfflineEntryPage({Key key}) : super(key: key);

  @override
  _AddOfflineEntryPageState createState() => _AddOfflineEntryPageState();
}

class _AddOfflineEntryPageState extends State<AddOfflineEntryPage> {
  List<DetailedActivity> activities;
  DetailedActivity selectedActivity;
  bool isConnectedToStrava = false;
  bool isLoading = false;

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
        this.activities = loadedActivites;
        this.isLoading = false;
      });
    });
  }

  void submitOfflineEntry() async {
    if (this.selectedActivity == null) {
      return;
    }

    DetailedActivity stravaActivity = this.selectedActivity;
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
      mapPath: stravaActivity.map.polyline,
      startLocation: stravaActivity.startLatlng,
    );

    final result =
        await offlineChartResource.submitEntry(model, authResource.getToken());

    //TODO: error handling
    if (result["answer"]) {
      Navigator.of(context).pushNamed("/");
    }
  }

  void toggleActivity(DetailedActivity activity) {
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
    return RaisedButton(
      child: Image(
        image: AssetImage('assets/btn_strava_connectwith_orange@2x.png'),
      ),
      onPressed: this.triggerStravaAuth,
    );
  }

  Widget _buildList(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(
        child: StravaActivityList(
            activities: this.activities,
            selectedActivity: this.selectedActivity,
            onActivityTap: toggleActivity),
      ),
      RaisedButton(
          onPressed: this.selectedActivity != null ? submitOfflineEntry : null,
          child: Text("Submit offline entry")),
    ]);
  }
}

class StravaActivityList extends StatelessWidget {
  final List<DetailedActivity> activities;
  final DetailedActivity selectedActivity;
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
      return Text("няма подходящи бягания");
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
    final date = DateTime.tryParse(activity.startDate);
    final dateString = date != null ? dateFromat.format(date) : "n/a";
    return Card(
      color: this.selectedActivity == activity
          ? Colors.blueGrey // TODO: Color?
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
                  ListTileRow(text: activity.name, icon: Icons.info),
                  ListTileRow(text: dateString, icon: Icons.calendar_today),
                  ListTileRow(
                      text: activity.distance.parseMetersToKilometers(),
                      icon: Icons.map),
                  ListTileRow(
                      text: activity.elapsedTime.parseSecondsToTimestamp(),
                      icon: Icons.timer),
                ],
              ),
            ),
            Container(
              width: 140,
              child: Image.network(
                "https://maps.googleapis.com/maps/api/staticmap?size=140x140&zoom=13&path=weight:3%7Ccolor:blue%7Cenc:" +
                    activity.map.polyline +
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
