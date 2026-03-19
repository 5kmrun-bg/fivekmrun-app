import 'package:fivekmrun_flutter/common/results_list.dart';
import 'package:fivekmrun_flutter/common/select_button.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/offline_results_resource.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OfflineChartPage extends StatefulWidget {
  OfflineChartPage({Key? key}) : super(key: key);

  @override
  _OfflineChartPageState createState() => _OfflineChartPageState();
}

class _OfflineChartPageState extends State<OfflineChartPage> {
  bool thisWeekSelected = true;
  List<Result>? results;
  OfflineResultsResource lastWeekResource = OfflineResultsResource();
  OfflineResultsResource thisWeekResource = OfflineResultsResource();

  selectThisWeek() {
    if (this.thisWeekSelected) {
      return;
    }
    setState(() {
      this.thisWeekSelected = true;
    });

    this._loadThisWeekResult();
  }

  selectLastWeek() {
    if (!this.thisWeekSelected) {
      return;
    }

    setState(() {
      this.thisWeekSelected = false;
    });

    this._loadLastWeekResult();
  }

  void goToAddEntry() {
    final authResource =
        Provider.of<AuthenticationResource>(context, listen: false);

    if (authResource.isLoggedIn()) {
      Navigator.of(context).pushNamed("/add");
    } else {
      this.showLogoutDialog();
    }
  }

  void showLogoutDialog() {
    final authResource =
        Provider.of<AuthenticationResource>(context, listen: false);
    final textStlyle = Theme.of(context).textTheme.titleSmall;
    final accentColor = Theme.of(context).colorScheme.secondary;
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(AppLocalizations.of(context)!.offline_chart_page_login),
          content: RichText(
            text: TextSpan(
              style: textStlyle,
              children: <TextSpan>[
                TextSpan(text: AppLocalizations.of(context)!.offline_chart_page_participation_in),
                TextSpan(
                  text: 'Selfie',
                  style: textStlyle?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: AppLocalizations.of(context)!.offline_chart_page_leaderboard_access),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: new Text(AppLocalizations.of(context)!.offline_chart_page_login),
              onPressed: () async {
                await authResource.logout();
                Provider.of<UserResource>(context, listen: false).clear();
                Provider.of<RunsResource>(context, listen: false).clear();

                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil("/", (_) => false);
              },
            ),
            TextButton(
              child: new Text(AppLocalizations.of(context)!.offline_chart_page_cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    this._loadThisWeekResult();
  }

  _loadLastWeekResult() {
    setState(() {
      this.results = null;
      this.lastWeekResource.getPastWeekResults().then((loadedResults) {
        this.setState(() => this.results = loadedResults);
      });
    });
  }

  _loadThisWeekResult() {
    setState(() {
      this.results = null;
      this.thisWeekResource.getThisWeekResults().then((loadedResults) {
        this.setState(() => this.results = loadedResults);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStlyle = Theme.of(context).textTheme.titleLarge;
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: textStlyle,
            children: <TextSpan>[
              TextSpan(
                  text:
                      AppLocalizations.of(context)!.offline_chart_page_weekly),
              TextSpan(
                text: 'Selfie',
                style: textStlyle?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: AppLocalizations.of(context)!.offline_chart_page_leaderboard),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SelectButton(
                  text: AppLocalizations.of(context)!.offline_chart_page_previous_week,
                  onPressed: this.selectLastWeek,
                  selected: !this.thisWeekSelected,
                ),
                SelectButton(
                  text: AppLocalizations.of(context)!.offline_chart_page_current_week,
                  onPressed: this.selectThisWeek,
                  selected: this.thisWeekSelected,
                ),
              ],
            ),
            Expanded(child: this._buildResults()),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: ElevatedButton(
                    onPressed: () => this.goToAddEntry(),
                    child: Row(
                      children: [
                        Text(
                            AppLocalizations.of(context)!
                                .offline_chart_page_join,
                            style: TextStyle()),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Icon(Icons.add_circle_outline),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                      onPressed: () => {
                            launch(
                              "https://5kmrun.bg/selfie/ofc",
                            )
                          },
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                .offline_chart_page_results,
                            style: TextStyle(
                              fontSize: 8,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.open_in_browser),
                          )
                        ],
                      )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (this.results == null) {
      return Center(child: CircularProgressIndicator());
    } else if (this.results?.length == 0) {
      return Center(
          child: Text(
              AppLocalizations.of(context)!.offline_chart_page_no_results));
    } else {
      return ResultsList(results: this.results!);
    }
  }
}
