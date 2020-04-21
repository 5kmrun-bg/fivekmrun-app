import 'package:fivekmrun_flutter/common/milestone_gauge.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:fivekmrun_flutter/state/results_resource.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';

class RunDetailsPage extends StatelessWidget {
  const RunDetailsPage({Key key}) : super(key: key);

  Widget buildPositionGauge(Run run) {
    ResultsResource results = ResultsResource();
    return FutureBuilder<List<Result>>(
        future: results.load(id: run.eventId),
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
                return MilestoneGauge(run.position, 400);
              else
                return MilestoneGauge(run.position, snapshot.data.length);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final Run run = ModalRoute.of(context).settings.arguments;
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
                Expanded(
                    flex: 3,
                    child: Column(
                      children: <Widget>[
                        CircleWidget(run.pace, "мин/км"),
                        SizedBox(height: 10),
                        Text(
                          "Темпо",
                          style: theme.textTheme.subtitle,
                        ),
                      ],
                    )),
                Expanded(
                    flex: 4,
                    child: Stack(
                      children: <Widget>[
                        buildPositionGauge(run),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Text(
                            "Позиция",
                            style: theme.textTheme.title,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )),
                Expanded(
                    flex: 3,
                    child: Column(
                      children: <Widget>[
                        CircleWidget(run.speed, "км/ч"),
                        SizedBox(height: 10),
                        Text(
                          "Скорост",
                          style: theme.textTheme.subtitle,
                        )
                      ],
                    )),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconText(
                  icon: Icons.calendar_today,
                  text: run.displayDate,
                ),
                IconText(
                  icon: Icons.timer,
                  text: run.time + " мин.",
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconText(
                  icon: Icons.pin_drop,
                  text: run.location,
                ),
              ],
            ),
            SizedBox(height: 16),
            ComapreTime(
              text: "Предишно бягане: ",
              time: run.differenceFromPrevious,
            ),
            SizedBox(height: 10),
            ComapreTime(
              text: "Най-добро бягане: ",
              time: run.differenceFromBest,
            ),
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
        Theme.of(context).textTheme.subhead.copyWith(color: Colors.black);
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
  const IconText({Key key, this.icon, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: theme.accentColor,
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            text,
            style: theme.textTheme.title,
          ),
        ),
      ],
    );
  }
}

class ComapreTime extends StatelessWidget {
  final int time;
  final String text;
  const ComapreTime({Key key, this.time, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final color = time < 0
        ? Color.fromRGBO(170, 208, 124, 1)
        : Color.fromRGBO(248, 91, 56, 1);

    final numberStyle = textTheme.subtitle.copyWith(color: color);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          text,
          style: textTheme.subtitle,
        ),
        Text(
          Run.timeInSecondsToString(time, sign: true),
          style: numberStyle,
        ),
      ],
    );
  }
}
