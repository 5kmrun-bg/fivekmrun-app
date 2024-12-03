import 'package:fivekmrun_flutter/custom_icons.dart';
import 'package:fivekmrun_flutter/offline_chart/details_tile.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';
import 'package:fivekmrun_flutter/private/secrets.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class OfflineChartDetailsPage extends StatelessWidget {
  OfflineChartDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Result result = ModalRoute.of(context)?.settings.arguments as Result;
    final iconColor = Theme.of(context).colorScheme.secondary;
    final imgSize = MediaQuery.of(context).size.width.round() - 32;

    final mapUrl =
        "https://maps.googleapis.com/maps/api/staticmap?size=${imgSize}x${imgSize}&zoom=14&maptype=terrain&path=weight:3%7Ccolor:0xFC1851%7Cenc:" +
            result.mapPolyline +
            "&key=" +
            googleMapsKey;
    return Scaffold(
      appBar: AppBar(
        title: Text(result.name, style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            onPressed: () => launch(
                "https://5kmrun.bg/selfie/user/" + result.userId.toString(),
                forceSafariVC: false),
            icon: Icon(Icons.person),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            iconSize: 20,
          ),
          if (result.stravaLink != null && result.stravaLink != "")
            IconButton(
              onPressed: () => launch(
                  "https://www.strava.com/activities/" + result.stravaLink!,
                  forceSafariVC: false),
              icon: Icon(CustomIcons.strava),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              iconSize: 20,
            )
        ],
      ),
      body: ListView(children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    SizedBox(
                      height: imgSize.toDouble(),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    FadeInImage.memoryNetwork(
                      image: mapUrl,
                      fit: BoxFit.fitWidth,
                      height: imgSize.toDouble(),
                      placeholder: kTransparentImage,
                      alignment: Alignment.topCenter,
                    ),
                  ],
                ),
                IntrinsicHeight(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            DetailsTile(
                              title: AppLocalizations.of(context)!.offline_chart_details_page_date,
                              value: DateFormat("dd.MM.yyyy")
                                  .format(result.startDate!),
                              accentColor: iconColor,
                            ),
                            DetailsTile(
                              title: AppLocalizations.of(context)!.offline_chart_details_page_position,
                              value: result.officialPosition.toString(),
                              accentColor: iconColor,
                            ),
                            DetailsTile(
                              title: AppLocalizations.of(context)!.offline_chart_details_page_time,
                              value: '${result.time} ${AppLocalizations.of(context)!.min}',
                              accentColor: iconColor,
                            ),
                            if (result.totalTime.isNotEmpty)
                              DetailsTile(
                                title: AppLocalizations.of(context)!.offline_chart_details_page_total_time,
                                value: '${result.totalTime} ${AppLocalizations.of(context)!.min}',
                                accentColor: iconColor,
                              ),
                            DetailsTile(
                              title: AppLocalizations.of(context)!.offline_chart_details_page_pace,
                              value: result.pace + " ${AppLocalizations.of(context)!.min_km}",
                              accentColor: iconColor,
                            ),
                            DetailsTile(
                              title: AppLocalizations.of(context)!.offline_chart_details_page_total_elevation_gained,
                              value: result.elevationGainedTotal
                                      .round()
                                      .toString() +
                                  " m",
                              accentColor: iconColor,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                        width: 5,
                      ),
                      VerticalDivider(
                        color: iconColor,
                        width: 5,
                        indent: 10,
                        endIndent: 10,
                      ),
                      SizedBox(
                        height: 10,
                        width: 5,
                      ),
                      Expanded(
                          child: Column(
                        children: <Widget>[
                          DetailsTile(
                            title: AppLocalizations.of(context)!.offline_chart_details_page_hour,
                            value:
                                DateFormat("HH:mm").format(result.startDate!),
                            accentColor: iconColor,
                          ),
                          DetailsTile(
                            title: AppLocalizations.of(context)!.offline_chart_details_page_location,
                            value: result.startLocation,
                            accentColor: iconColor,
                          ),
                          DetailsTile(
                            title: AppLocalizations.of(context)!.offline_chart_details_page_distance,
                            value: '${result.distance.toString()} m',
                            accentColor: iconColor,
                          ),
                          if (result.totalDistance > result.distance)
                            DetailsTile(
                              title:AppLocalizations.of(context)!.offline_chart_details_page_total_distance,
                              value: '${result.totalDistance.toString()} m',
                              accentColor: iconColor,
                            ),
                          DetailsTile(
                            title: AppLocalizations.of(context)!.offline_chart_details_page_elevation,
                            value: result.elevationLow.toStringAsFixed(0) +
                                " m - " +
                                result.elevationHigh.toStringAsFixed(0) +
                                " m",
                            accentColor: iconColor,
                          ),
                          if (result.status > 0 && result.status <= 2)
                            DetailsTile(
                              title: AppLocalizations.of(context)!.offline_chart_details_page_status,
                              value: AppLocalizations.of(context)!.offline_chart_details_page_confirmed,
                              accentColor: iconColor,
                            ),
                          if (result.status == 3)
                            DetailsTile(
                              title: AppLocalizations.of(context)!.offline_chart_details_page_status,
                              value: AppLocalizations.of(context)!.offline_chart_details_page_independent,
                              accentColor: iconColor,
                            ),
                          if (result.status > 3 && result.status <= 5)
                            DetailsTile(
                              title: AppLocalizations.of(context)!.offline_chart_details_page_status,
                              value: AppLocalizations.of(context)!.offline_chart_details_page_disqualified,
                              accentColor: iconColor,
                            ),
                        ],
                      ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
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
            style: theme.textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}

class ComapreTime extends StatelessWidget {
  final int time;
  final String text;
  const ComapreTime({Key? key, required this.time, required this.text})
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
