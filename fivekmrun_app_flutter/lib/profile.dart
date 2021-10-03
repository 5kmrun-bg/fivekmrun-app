import 'package:fivekmrun_flutter/charts/best_times_by_route_chart.dart';
import 'package:fivekmrun_flutter/charts/runs_by_route_chart.dart';
import 'package:fivekmrun_flutter/common/avatar.dart';
import 'package:fivekmrun_flutter/common/run_card.dart';
import 'package:fivekmrun_flutter/custom_icons.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'charts/runs_chart.dart';
import 'common/milestone.dart';

class ProfileDashboard extends StatelessWidget {
  const ProfileDashboard({Key? key}) : super(key: key);

  int nextRunsMilestone(int count) {
    if (count <= 50) {
      return 50;
    } else if (count <= 100) {
      return 100;
    } else if (count <= 250) {
      return 250;
    } else {
      return 500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userResource = Provider.of<UserResource>(context);
    final runsRes = Provider.of<RunsResource>(context);

    final user = userResource.value;
    final textTheme = Theme.of(context).textTheme;

    final runs = runsRes.value;
    final hasAnyRuns = runs != null && runs.length > 0;
    final hasOfficialRuns =
        runs != null && runs.where((r) => !r.isSelfie).length > 0;
    final hasSelfieRuns =
        runs != null && runs.where((r) => r.isSelfie).length > 0;

    print("HAS ANY RUNS: " + hasAnyRuns.toString());
    final goToSettings = () {
      Navigator.of(context, rootNavigator: true).pushNamed("settings");
    };

    final goToBarcode = () {
      Navigator.of(context, rootNavigator: true).pushNamed("barcode");
    };

    return ListView(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(CustomIcons.barcode),
                    onPressed: goToBarcode,
                  ),
                  MilestoneTile(
                      value: runsRes.value
                              ?.where((r) => r.isSelfie)
                              .length
                              .toInt() ??
                          0,
                      milestone: nextRunsMilestone(runsRes.value
                              ?.where((r) => r.isSelfie)
                              .length
                              .toInt() ??
                          50),
                      title: "Легионер\nselfie"),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                children: <Widget>[
                  Avatar(url: user?.avatarUrl ?? ""),
                  Text(
                    user?.name ?? "",
                    style: textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                  Text(""),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: goToSettings,
                  ),
                  MilestoneTile(
                      value: runsRes.value
                              ?.where((r) => !r.isSelfie)
                              .length
                              .toInt() ??
                          0,
                      milestone: nextRunsMilestone(runsRes.value
                              ?.where((r) => !r.isSelfie)
                              .length
                              .toInt() ??
                          50),
                      title: "Легионер\nсъщинско"),
                ],
              ),
            ),
          ],
        ),
        if (runsRes.loading) Center(child: CircularProgressIndicator()),
        if (hasOfficialRuns)
          this.buildRunsCards(
              runsRes.bestOfficialRun!, runsRes.lastOfficialRun!, "същинско"),
        if (hasSelfieRuns)
          this.buildRunsCards(
              runsRes.bestSelfieRun!, runsRes.lastSelfieRun!, "selfie"),
        if (hasAnyRuns) this.buildRunsChartCard(runs!),
        if (!runsRes.loading && !hasAnyRuns)
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text("Все още не сте направили първото си бягане"),
                  ),
                ),
              )
            ],
          ),
        if (hasOfficialRuns) this.buildRunsByRouteCard(runs!),
        if (hasOfficialRuns) this.buildBestTimesCard(runs!),
      ],
    );
  }

  Widget buildRunsCards(Run bestRun, Run lastRun, String runType) {
    return Row(
      children: <Widget>[
        Expanded(
          child: RunCard(
            title: "Последно " + runType,
            run: lastRun,
          ),
        ),
        Expanded(
          child: RunCard(
            title: "Най-добро " + runType,
            run: bestRun,
          ),
        ),
      ],
    );
  }

  Widget buildRunsChartCard(List<Run> runs) {
    return Card(
      child: Container(
        height: 200,
        child: RunsChart(runs: runs.take(30).toList()),
      ),
    );
  }

  Widget buildRunsByRouteCard(List<Run> runs) {
    return Card(
      child: Container(
        height: 200,
        child: RunsByRouteChart.withRuns(runs),
      ),
    );
  }

  Widget buildBestTimesCard(List<Run> runs) {
    return Card(
      child: Container(
        height: 350,
        child: BestTimesByRouteChart.withRuns(runs),
      ),
    );
  }
}
