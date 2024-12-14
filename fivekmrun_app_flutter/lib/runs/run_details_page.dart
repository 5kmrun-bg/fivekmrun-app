import 'package:fivekmrun_flutter/common/milestone_gauge.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:fivekmrun_flutter/state/results_resource.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RunDetailsPage extends StatelessWidget {
  const RunDetailsPage({Key? key}) : super(key: key);

  Widget buildPositionGauge(Run run) {
    if (run.isSelfie) return SizedBox.shrink();

    ResultsResource results = ResultsResource();
    return FutureBuilder<List<Result>>(
        future: results.getAll(run.eventId!),
        builder: (BuildContext context, AsyncSnapshot<List<Result>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return AspectRatio(
                aspectRatio: 1,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            case ConnectionState.done:
              if (snapshot.hasError)
                return MilestoneGauge(run.position!, 400,
                    Theme.of(context).colorScheme.secondary);
              else
                return MilestoneGauge(run.position!, snapshot.data?.length ?? 0,
                    Theme.of(context).colorScheme.secondary);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final Run run = ModalRoute.of(context)?.settings.arguments as Run;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(run.displayDate)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(flex: 2, child: SizedBox()),
                Expanded(
                    flex: 3,
                    child: Stack(
                      children: <Widget>[
                        buildPositionGauge(run),
                        Positioned(
                          bottom: 6,
                          left: 0,
                          right: 0,
                          child: Text(
                            AppLocalizations.of(context)!.run_details_page_position,
                            style: theme.textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )),
                Expanded(flex: 2, child: SizedBox()),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    CircleWidget(run.pace!, AppLocalizations.of(context)!.min_km),
                    SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.run_details_page_pace,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    CircleWidget(run.time!, AppLocalizations.of(context)!.min),
                    SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.run_details_page_time,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    CircleWidget(run.speed!, AppLocalizations.of(context)!.km_per_h),
                    SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.run_details_page_speed,
                      style: theme.textTheme.titleSmall,
                    )
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconText(
                  icon: Icons.calendar_today,
                  text: run.displayDate,
                ),
                IconText(
                  icon: Icons.pin_drop,
                  text: (run.isSelfie) ? "Selfie" : run.location!,
                ),
              ],
            ),
            if (run.isSelfie)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconText(icon: Icons.watch, text: run.totalTime! + " ${AppLocalizations.of(context)!.min}"),
                  IconText(
                      icon: Icons.straighten,
                      text: (run.distance! / 1000).toStringAsFixed(2) + " ${AppLocalizations.of(context)!.km}"),
                ],
              ),
            SizedBox(height: 20),
            // if (!run.isSelfie)
            //   CompareTime(
            //     text: "Предишно бягане: ",
            //     time: run.differenceFromPrevious,
            //   ),
            // if (!run.isSelfie) SizedBox(height: 10),
            // if (!run.isSelfie)
            //   CompareTime(
            //     text: "Най-добро бягане: ",
            //     time: run.differenceFromBest,
            //   ),
          ],
        ),
      ),
    );
  }
}

class CircleWidget extends StatelessWidget {
  final String value;
  final String measurement;

  CircleWidget(this.value, this.measurement);

  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.black);
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Text(this.value, style: textStyle),
          Text(this.measurement, style: textStyle)
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  const IconText({Key? key, required this.icon, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: theme.colorScheme.secondary,
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            text,
            style: theme.textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}

class CompareTime extends StatelessWidget {
  final int time;
  final String text;
  const CompareTime({Key? key, required this.time, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final color = time < 0
        ? Color.fromRGBO(0, 173, 25, 1)
        : Color.fromRGBO(250, 32, 87, 1);

    final numberStyle = textTheme.titleSmall?.copyWith(color: color);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          text,
          style: textTheme.titleSmall,
        ),
        Text(
          Run.timeInSecondsToString(time, sign: true),
          style: numberStyle,
        ),
      ],
    );
  }
}

class RunDetail extends StatelessWidget {
  final String value;
  final String label;
  const RunDetail({Key? key, required this.value, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          label,
          style: textTheme.titleSmall,
        ),
        Text(
          value,
          style: textTheme.titleSmall,
        ),
      ],
    );
  }
}
