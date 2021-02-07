import 'package:fivekmrun_flutter/home.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RunCard extends StatelessWidget {
  final Run run;
  final String title;

  const RunCard({Key key, this.run, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.accentColor;
    final textTheme = theme.textTheme;
    final labelStyle = theme.textTheme.body1;
    final valueStyle = theme.textTheme.body2;

    return GestureDetector(
      onTap: () {
        final tabHelper =
            Provider.of<TabNavigationHelper>(context, listen: false);
        tabHelper.selectTab(AppTab.runs);
        tabHelper.pushToTab(AppTab.runs, "/run-details", arguments: run);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(title, style: textTheme.subhead),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                      child: 
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            run.position.toString(),
                            style: textTheme.title
                                .copyWith(color: theme.accentColor), //HACK: hide the label if Selfie but bump the space
                          ),
                          Text("място", style: labelStyle),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Icon(Icons.calendar_today, size: 16, color: iconColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Icon(Icons.directions_run,
                              size: 16, color: iconColor),
                        ),
                        Icon(Icons.timer, size: 16, color: iconColor)
                      ],
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(run.displayDate,
                              style: valueStyle,
                              overflow: TextOverflow.ellipsis),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(run.pace + " мин/км",
                                style: valueStyle,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(run.time + " мин",
                              style: valueStyle,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
