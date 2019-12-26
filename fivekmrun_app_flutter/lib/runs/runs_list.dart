import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final DateFormat dateFromat = DateFormat("dd.MM.yyyy");

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
            return Card(
              child: Column(
                children: <Widget>[
                  ListTileRow(
                    icon: Icons.calendar_today,
                    text: dateFromat.format(runs[index].date),
                  ),
                  ListTileRow(
                    icon: Icons.pin_drop,
                    text: runs[index].location,
                  ),
                  ListTileRow(
                    icon: Icons.timer,
                    text: runs[index].time,
                  ),
                ],
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
