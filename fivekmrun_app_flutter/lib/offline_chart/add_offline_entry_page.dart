import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/private/secrets.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/offline_chart_resource.dart';
import 'package:fivekmrun_flutter/state/offline_chart_submission_model.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/strava_activity_model.dart';
import 'package:fivekmrun_flutter/state/strava_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';
import 'package:strava_flutter/domain/model/model_detailed_activity.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/int_extensions.dart';
import '../common/double_extensions.dart';
import 'package:geocoding/geocoding.dart';

import 'no_results_component.dart';

final DateFormat dateFromat = DateFormat(Constants.DATE_FORMAT);

typedef void ActivityPressedCB(StravaSummaryRun activity);

class AddOfflineEntryPage extends StatefulWidget {
  AddOfflineEntryPage({Key? key}) : super(key: key);

  @override
  _AddOfflineEntryPageState createState() => _AddOfflineEntryPageState();
}

class _AddOfflineEntryPageState extends State<AddOfflineEntryPage> {
  List<StravaSummaryRun>? activities;
  StravaSummaryRun? selectedActivity;
  bool isConnectedToStrava = false;
  bool isLoading = true;
  ButtonState submitButtonState = ButtonState.idle;

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

  Future<String> getActivityLocation(DetailedActivity? activity) async {
    if (activity == null ||
        activity.startLatlng == null ||
        activity.startLatlng!.length != 2) {
      return "";
    }
    var placemark = await placemarkFromCoordinates(
        activity.startLatlng!.first, activity.startLatlng!.last);

    var locality = placemark.first.locality;
    var country = placemark.first.country;

    await setLocaleIdentifier('en_US');

    if (locality == null || country == null) {
      return "";
    } else {
      return "$locality, $country";
    }
  }

  void submitOfflineEntry() async {
    setState(() {
      submitButtonState = ButtonState.loading;
    });
    if (this.selectedActivity == null) {
      return;
    }
    StravaSummaryRun? runSummary = this.selectedActivity;

    DetailedActivity? stravaActivity = this.selectedActivity?.detailedActivity;
    UserResource userResource =
        Provider.of<UserResource>(context, listen: false);
    AuthenticationResource authResource =
        Provider.of<AuthenticationResource>(context, listen: false);
    OfflineChartResource offlineChartResource =
        Provider.of<OfflineChartResource>(context, listen: false);

    var segments =
        stravaActivity?.segmentEfforts?.map((s) => s.segment?.id).toList();
    print("segments: " + json.encode(segments));
    OfflineChartSubmissionModel model = new OfflineChartSubmissionModel(
      userId: userResource.currentUserId.toString(),
      elapsedTime: runSummary?.fastestSplit.elapsedTime.floor() ?? 0,
      distance: runSummary?.fastestSplit.distance ?? 0,
      startDate: DateTime.parse(stravaActivity?.startDateLocal ?? ""),
      mapPath: stravaActivity?.map!.polyline ?? "",
      startGeoLocation: stravaActivity?.startLatlng ?? [0],
      elevationGainedTotal: stravaActivity?.totalElevationGain ?? 0,
      elevationLow: stravaActivity?.elevLow ?? 0,
      elevationHigh: stravaActivity?.elevHigh ?? 0,
      totalDistance: stravaActivity?.distance ?? 0,
      totalElapsedTime: stravaActivity?.elapsedTime ?? 0,
      startLocation: await getActivityLocation(stravaActivity),
      stravaLink: stravaActivity?.id.toString() ?? "",
      segments: segments,
    );

    FirebaseCrashlytics.instance
        .log("5kmRun Submission model: " + jsonEncode(model.toJson()));

    Map<String, dynamic> result;
    try {
      result = await offlineChartResource.submitEntry(
          model, authResource.getToken() ?? "");
    } on Exception catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      showDialog(
          context: context,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!
                  .add_offline_entry_page_server_error),
              content: Text(AppLocalizations.of(context)!
                  .add_offline_entry_page_data_error),
              actions: <Widget>[
                TextButton(
                    child: Text(AppLocalizations.of(context)!
                        .add_offline_entry_page_ok),
                    onPressed: () => Navigator.of(context).pop())
              ],
            );
          });
      return;
    }

    if (result["errors"] != null && result["errors"].length > 0) {
      setState(() {
        submitButtonState = ButtonState.fail;
      });
      if (result["errors"].contains("403")) {
        FirebaseCrashlytics.instance.recordError(
            Exception("Unexpected invalid 5kmRun token"), StackTrace.current);
        final textStlyle = Theme.of(context).textTheme.titleSmall;
        showDialog(
          context: context,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text(AppLocalizations.of(context)!
                  .add_offline_entry_page_authentication_error),
              content: RichText(
                text: TextSpan(
                  style: textStlyle,
                  children: <TextSpan>[
                    TextSpan(
                        text: AppLocalizations.of(context)!
                            .add_offline_entry_page_login_again),
                  ],
                ),
              ),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                TextButton(
                  child: new Text(AppLocalizations.of(context)!
                      .add_offline_entry_page_login),
                  onPressed: () async {
                    await authResource.logout();
                    Provider.of<UserResource>(context, listen: false).clear();
                    Provider.of<RunsResource>(context, listen: false).clear();

                    Navigator.of(context, rootNavigator: true)
                        .pushNamedAndRemoveUntil("/", (_) => false);
                  },
                ),
                TextButton(
                  child: new Text(AppLocalizations.of(context)!
                      .add_offline_entry_page_cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        FirebaseCrashlytics.instance.recordError(
            Exception(result["errors"].toString()), StackTrace.current);
        showDialog(
          context: context,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text(AppLocalizations.of(context)!
                  .add_offline_entry_page_server_sending_error),
              actions: <Widget>[
                TextButton(
                    child: Text(AppLocalizations.of(context)!.add_offline_entry_page_ok),
                    onPressed: () => Navigator.of(context).pop())
              ],
              content: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            AppLocalizations.of(context)!.add_offline_entry_page_data_error),
                  ],
                ),
              ),
            );
          },
        );
      }
    }

    if (result["answer"]) {
      setState(() {
        submitButtonState = ButtonState.success;
      });
      submitButtonState = ButtonState.success;
      FirebaseAnalytics.instance.logEvent(name: "submit_selfie_entry");
      Navigator.of(context).pushNamed("/");
    } else {
      setState(() {
        submitButtonState = ButtonState.fail;
      });
      submitButtonState = ButtonState.fail;
      FirebaseCrashlytics.instance.recordError(
          Exception("Error from 5kmrun: " + result.toString()),
          StackTrace.current);
    }
  }

  void toggleActivity(StravaSummaryRun activity) {
    this.setState(() => this.selectedActivity =
        this.selectedActivity == activity ? null : activity);
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
        title: Text(AppLocalizations.of(context)!.add_offline_entry_page_join_leaderboard),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
          child: Text(
            AppLocalizations.of(context)!
                .add_offline_entry_page_join_leaderboard_instructions,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          height: 20,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.all(0)),
          child: Image(
            image: AssetImage('assets/btn_strava_connectwith_orange.png'),
          ),
          onPressed: this.triggerStravaAuth,
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    var selectedColor = Theme.of(context).colorScheme.secondary;

    return Column(
      children: <Widget>[
        Expanded(
          child: StravaActivityList(
              activities: this.activities!,
              selectedActivity: this.selectedActivity,
              onActivityTap: toggleActivity),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: ProgressButton.icon(
              iconedButtons: {
                ButtonState.idle: IconedButton(
                    text: AppLocalizations.of(context)!
                        .add_offline_entry_page_join_with_current_run,
                    icon: Icon(Icons.send, color: Colors.white),
                    color: selectedColor),
                ButtonState.loading: IconedButton(
                    text: AppLocalizations.of(context)!
                        .add_offline_entry_page_sending,
                    color: selectedColor),
                ButtonState.fail: IconedButton(
                    text: AppLocalizations.of(context)!
                        .add_offline_entry_page_uploading_error,
                    icon: Icon(Icons.cancel, color: Colors.white),
                    color: selectedColor),
                ButtonState.success: IconedButton(
                    text: "",
                    icon: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    color: Colors.green.shade400)
              },
              state: submitButtonState,
              onPressed: this.selectedActivity != null
                  ? () async {
                      submitOfflineEntry();
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
  final StravaSummaryRun? selectedActivity;
  final ActivityPressedCB onActivityTap;

  const StravaActivityList(
      {Key? key,
      required this.activities,
      required this.selectedActivity,
      required this.onActivityTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activities.length == 0) {
      return NoResultsComponent();
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
    final date = DateTime.tryParse(activity.detailedActivity.startDate!);
    final dateString = date != null ? dateFromat.format(date) : "n/a";
    final selectedColor = Colors.blueGrey.shade700;

    final totalTime =
        activity.detailedActivity.elapsedTime!.parseSecondsToTimestamp();
    final totalDistance = activity.detailedActivity.distance!.metersToKm();

    final fastestSplitTime =
        activity.fastestSplit.elapsedTime.floor().parseSecondsToTimestamp();
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
                  ListTileRow(
                      text: activity.detailedActivity.name!, icon: Icons.info),
                  ListTileRow(text: dateString, icon: Icons.calendar_today),
                  ListTileRow(
                      text: "$fastestSplitDistance / $totalDistance ${AppLocalizations.of(context)!.km}",
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
                    activity.detailedActivity.map!.polyline! +
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
