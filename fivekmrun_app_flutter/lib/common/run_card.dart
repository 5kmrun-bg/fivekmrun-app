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
    final textTheme = theme.textTheme;
    final labelStyle = theme.textTheme.body1;
    final valueStyle = theme.textTheme.body2;

    return GestureDetector(
      onTap: () {
        final tabHelper = Provider.of<TabNavigationHelper>(context);
        tabHelper.selectTab(AppTab.runs);
        tabHelper.pushToTab(AppTab.runs, "/run-details", arguments: run);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(title, style: textTheme.subhead),
              if (run != null)
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              run.position.toString(),
                              style: textTheme.title
                                  .copyWith(color: theme.accentColor),
                            ),
                            Text("място", style: labelStyle),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text("Дата: ", style: labelStyle),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text("Темпо: ", style: labelStyle),
                          ),
                          Text("Време: ", style: labelStyle),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(run.displayDate, style: valueStyle, overflow: TextOverflow.ellipsis),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(run.pace, style: valueStyle, overflow: TextOverflow.ellipsis),
                            ),
                            Text(run.time, style: valueStyle, overflow: TextOverflow.ellipsis),
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
