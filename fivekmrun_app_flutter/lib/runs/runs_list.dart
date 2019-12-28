import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RunsList extends StatelessWidget {
  const RunsList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RunsResource>(builder: (context, userResource, child) {
      final runs = userResource.value;
      if (runs != null) {
        return ListView.builder(
          itemCount: runs.length,
          itemBuilder: (BuildContext context, int index) {
            final run = runs[index];
            return Card(
              child: ListTile(
                title: Column(
                  children: <Widget>[
                    ListTileRow(
                      icon: Icons.calendar_today,
                      text: run.displayDate,
                    ),
                    ListTileRow(
                      icon: Icons.pin_drop,
                      text: run.location,
                    ),
                    ListTileRow(
                      icon: Icons.timer,
                      text: run.time,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        return Text("loading"); // TODO: loading indicator
      }
    });
  }
}
