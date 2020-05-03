import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/common/milestone_gauge.dart';
import 'package:fivekmrun_flutter/custom_icons.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:fivekmrun_flutter/state/results_resource.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';
import 'package:fivekmrun_flutter/private/secrets.dart';

class OfflineChartDetailsPage extends StatelessWidget {
  const OfflineChartDetailsPage({Key key}) : super(key: key);

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
    final Result result = ModalRoute.of(context).settings.arguments;
    final iconColor = Theme.of(context).accentColor;

    return Scaffold(
      appBar: AppBar(title: Text(result.name)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    IntrinsicWidth(
                      child: Column(
                        children: <Widget>[
                          ListTileRow(
                            icon: CustomIcons.award,
                            text: result.officialPosition.toString(),
                            iconColor: iconColor,
                          ),
                          ListTileRow(
                            icon: Icons.timer,
                            text: result.time + " мин",
                            iconColor: iconColor,
                          ),
                          ListTileRow(
                            icon: Icons.directions_run,
                            text: result.pace + " мин/км",
                            iconColor: iconColor,
                          ),
                          ListTileRow(
                            icon: Icons.terrain,
                            text: result.elevationGainedTotal != null ? result.elevationGainedTotal.toString() + "m" : "-",
                            iconColor: iconColor,
                          ),
                        ],
                      ),
                    ),
                    VerticalDivider(
                      color: iconColor,
                      width: 5,
                      indent: 10,
                      endIndent: 10,
                    ),
                    SizedBox(height: 10, width: 10,),
                    Expanded(
                      child: Column(children: <Widget>[
                        ListTileRow(
                          icon: Icons.location_city,
                          text: result.startLocation ?? " - ",
                          iconColor: iconColor,
                        ),
                        ListTileRow(
                          icon: Icons.straighten,
                          text: result.distance.toString()+"m",
                          iconColor: iconColor,
                        ),
                        ListTileRow(
                          icon: Icons.trending_up,
                          text: result.elevationLow.toStringAsFixed(0) + "m ⬈ " + result.elevationHigh.toStringAsFixed(0) + "m",
                          iconColor: iconColor,
                        ),
                          if (result.status > 0 && result.status <= 2)
                            ListTileRow(
                              icon: Icons.check_box,
                              text: "доказан",
                              iconColor: iconColor,
                            ),
                          if (result.status == 3)
                            ListTileRow(
                              icon: Icons.check,
                              text: "самостоятелен",
                              iconColor: iconColor,
                            ),
                          if (result.status > 3 && result.status <= 5)
                            ListTileRow(
                              icon: Icons.error,
                              text: "дисквалифициран",
                              iconColor: iconColor,
                            ),
                      ],))
                  ],
                ),
              ),
            Image.network(
                "https://maps.googleapis.com/maps/api/staticmap?size=300x300&zoom=14&maptype=terrain&path=weight:3%7Ccolor:0xFC1851%7Cenc:" +
                    result.mapPolyline +
                    "&key=" +
                    googleMapsKey,
                fit: BoxFit.fitWidth,
              ),
            ],
          ),
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
        ? Color.fromRGBO(0, 173, 25, 1)
        : Color.fromRGBO(250, 32, 87, 1);

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
