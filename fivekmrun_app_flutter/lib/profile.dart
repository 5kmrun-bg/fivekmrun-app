import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fivekmrun_flutter/charts/best_times_by_route_chart.dart';
import 'package:fivekmrun_flutter/charts/runs_by_route_chart.dart';
import 'package:fivekmrun_flutter/common/avatar.dart';
import 'package:fivekmrun_flutter/common/badges.dart';
import 'package:fivekmrun_flutter/common/legioner_status_helper.dart';
import 'package:fivekmrun_flutter/common/run_card.dart';
import 'package:fivekmrun_flutter/constants.dart';
import 'package:fivekmrun_flutter/custom_icons.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:url_launcher/url_launcher.dart';

import 'charts/runs_chart.dart';
import 'common/milestone.dart';

class ProfileDashboard extends StatelessWidget {
  const ProfileDashboard({Key? key}) : super(key: key);

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

    Widget profileBadge() {
      if (hasMaxBadge(runs)) {
        return Image(
            height: 64,
            alignment: Alignment.bottomRight,
            image: AssetImage('assets/max-badge.png'));
      }

      if (hasSelfieBadge(runs)) {
        return Image(
            height: 64,
            alignment: Alignment.bottomRight,
            image: AssetImage('assets/selfie-badge.png'));
      }

      return SizedBox.shrink();
    }

    return ColorfulSafeArea(
        color: Color.fromRGBO(66, 66, 66, 0.7),
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: ListView(
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
                          milestone: LegionerStatusHelper.getNextMilestone(
                              runsRes.value
                                      ?.where((r) => r.isSelfie)
                                      .length
                                      .toInt() ??
                                  0),
                          title: "Легионер\nselfie"),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Avatar(url: user?.avatarUrl ?? ""),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: profileBadge(),
                          )
                        ],
                      ),
                      Text(
                        user?.name ?? "",
                        style: textTheme.titleMedium,
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
                      Row(children: <Widget>[
                        if (DateTime.now().month == 1 ||
                            (DateTime.now().month == 12 &&
                                DateTime.now().day >= 15))
                          ShakeWidget(
                              shakeConstant: ShakeSlowConstant1(),
                              autoPlay: true,
                              child: IconButton(
                                icon: const Icon(Icons.redeem),
                                color: Colors.red,
                                onPressed: () => launchUrl(
                                    Uri.parse(wrapUrl + user!.id.toString()),
                                    mode: LaunchMode.externalApplication),
                              )),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: goToSettings,
                        ),
                      ]),
                      MilestoneTile(
                          value: runsRes.value
                                  ?.where((r) => !r.isSelfie)
                                  .length
                                  .toInt() ??
                              0,
                          milestone: LegionerStatusHelper.getNextMilestone(
                              runsRes.value
                                      ?.where((r) => !r.isSelfie)
                                      .length
                                      .toInt() ??
                                  0),
                          title: "Легионер\nсъщинско"),
                    ],
                  ),
                ),
              ],
            ),
            if (runsRes.loading) Center(child: CircularProgressIndicator()),
            if (hasOfficialRuns)
              this.buildRunsCards(runsRes.bestOfficialRun!,
                  runsRes.lastOfficialRun!, "същинско"),
            if (hasSelfieRuns)
              this.buildRunsCards(
                  runsRes.bestSelfieRun!, runsRes.lastSelfieRun!, "selfie"),
            if (hasAnyRuns) this.buildRunsChartCard(runs),
            if (!runsRes.loading && !hasAnyRuns)
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child:
                            Text("Все още не сте направили първото си бягане"),
                      ),
                    ),
                  )
                ],
              ),
            if (hasOfficialRuns) this.buildRunsByRouteCard(runs),
            if (hasOfficialRuns) this.buildBestTimesCard(runs),
          ],
        ));
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
