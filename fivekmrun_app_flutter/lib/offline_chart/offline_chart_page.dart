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
          title: new Text("Вход с парола"),
          content: RichText(
            text: TextSpan(
              style: textStlyle,
              children: <TextSpan>[
                TextSpan(text: 'Участието в '),
                TextSpan(
                  text: 'Selfie',
                  style: textStlyle?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: ' класацията е достъпно вход с парола!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: new Text("Вход с парола"),
              onPressed: () async {
                await authResource.logout();
                Provider.of<UserResource>(context, listen: false).clear();
                Provider.of<RunsResource>(context, listen: false).clear();

                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil("/", (_) => false);
              },
            ),
            TextButton(
              child: new Text("Откажи"),
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
              TextSpan(text: 'Седмична '),
              TextSpan(
                text: 'Selfie',
                style: textStlyle?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: ' класация'),
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
                  text: "Предходна седмица",
                  onPressed: this.selectLastWeek,
                  selected: !this.thisWeekSelected,
                ),
                SelectButton(
                  text: "Текуща седмица",
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
                        Text("Участвай", style: TextStyle()),
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
                            "Подробни\nрезултати",
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
      return Center(child: Text("Няма резултати"));
    } else {
      return ResultsList(results: this.results!);
    }
  }
}
