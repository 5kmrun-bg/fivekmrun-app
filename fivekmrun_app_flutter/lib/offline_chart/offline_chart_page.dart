import 'package:fivekmrun_flutter/common/profile_switcher.dart';
import 'package:fivekmrun_flutter/common/refresh_helper.dart';
import 'package:fivekmrun_flutter/common/results_list.dart';
import 'package:fivekmrun_flutter/common/select_button.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/offline_results_resource.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';

class OfflineChartPage extends StatefulWidget {
  /// Injectable for tests; defaults to real resources in production.
  OfflineChartPage({
    Key? key,
    OfflineResultsResource? lastWeekResource,
    OfflineResultsResource? thisWeekResource,
  })  : lastWeekResource = lastWeekResource ?? OfflineResultsResource(),
        thisWeekResource = thisWeekResource ?? OfflineResultsResource(),
        super(key: key);

  final OfflineResultsResource lastWeekResource;
  final OfflineResultsResource thisWeekResource;

  @override
  _OfflineChartPageState createState() => _OfflineChartPageState();
}

class _OfflineChartPageState extends State<OfflineChartPage> {
  bool thisWeekSelected = true;
  List<Result>? results;

  selectThisWeek() {
    if (thisWeekSelected) {
      return;
    }
    setState(() {
      thisWeekSelected = true;
    });

    _loadThisWeekResult();
  }

  selectLastWeek() {
    if (!thisWeekSelected) {
      return;
    }

    setState(() {
      thisWeekSelected = false;
    });

    _loadLastWeekResult();
  }

  void goToAddEntry() {
    final authResource =
        Provider.of<AuthenticationResource>(context, listen: false);

    if (authResource.isLoggedIn()) {
      Navigator.of(context).pushNamed("/add");
    } else {
      showLogoutDialog();
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
          title:
              Text(AppLocalizations.of(context)!.offline_chart_page_login),
          content: RichText(
            text: TextSpan(
              style: textStlyle,
              children: <TextSpan>[
                TextSpan(
                    text: AppLocalizations.of(context)!
                        .offline_chart_page_participation_in),
                TextSpan(
                  text: 'Selfie',
                  style: textStlyle?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                    text: AppLocalizations.of(context)!
                        .offline_chart_page_leaderboard_access),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                  AppLocalizations.of(context)!.offline_chart_page_login),
              onPressed: () async {
                Navigator.of(context).pop();
                final profile = authResource.activeProfile;
                if (profile == null) return;
                await authenticateProfileWithPassword(this.context, profile);
              },
            ),
            TextButton(
              child: Text(
                  AppLocalizations.of(context)!.offline_chart_page_cancel),
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
    _loadThisWeekResult();
  }

  Future<void> _loadLastWeekResult() async {
    setState(() {
      results = null;
    });
    final loadedResults =
        await widget.lastWeekResource.getPastWeekResults();
    if (!mounted) return;
    setState(() => results = loadedResults);
  }

  Future<void> _loadThisWeekResult() async {
    setState(() {
      results = null;
    });
    final loadedResults =
        await widget.thisWeekResource.getThisWeekResults();
    if (!mounted) return;
    setState(() => results = loadedResults);
  }

  /// Backs the pull-to-refresh gesture on this tab, reloading whichever week
  /// is currently selected. Kept separate from [refreshAllData]: this page
  /// has its own week-scoped resources rather than the shared ones that
  /// helper refreshes.
  Future<void> _refresh() {
    return thisWeekSelected
        ? _loadThisWeekResult()
        : _loadLastWeekResult();
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
              TextSpan(
                  text: AppLocalizations.of(context)!
                      .offline_chart_page_leaderboard),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Center(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SelectButton(
                    text: AppLocalizations.of(context)!
                        .offline_chart_page_previous_week,
                    onPressed: selectLastWeek,
                    selected: !thisWeekSelected,
                  ),
                  SelectButton(
                    text: AppLocalizations.of(context)!
                        .offline_chart_page_current_week,
                    onPressed: selectThisWeek,
                    selected: thisWeekSelected,
                  ),
                ],
              ),
              Expanded(child: _buildResults()),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: ElevatedButton(
                      onPressed: () => goToAddEntry(),
                      child: Row(
                        children: [
                          Text(
                              AppLocalizations.of(context)!
                                  .offline_chart_page_join,
                              style: const TextStyle()),
                          const Padding(
                            padding: EdgeInsets.only(left: 8, right: 8),
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
                              launchUrl(
                                Uri.parse("https://5kmrun.bg/selfie/ofc"),
                              )
                            },
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .offline_chart_page_results,
                              style: const TextStyle(
                                fontSize: 8,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
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
      ),
    );
  }

  Widget _buildResults() {
    if (results == null) {
      return refreshableMessage(const CircularProgressIndicator());
    } else if (results?.length == 0) {
      return refreshableMessage(
          Text(AppLocalizations.of(context)!.offline_chart_page_no_results));
    } else {
      return ResultsList(results: results!);
    }
  }
}
