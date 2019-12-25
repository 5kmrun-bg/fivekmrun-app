import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

DateFormat dateFromat = DateFormat("dd.MM.yyyy");

class RunList extends StatelessWidget {
  const RunList({Key key}) : super(key: key);

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
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(dateFromat.format(runs[index].date)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.pin_drop),
                    title: Text(runs[index].place),

                  ),
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: Text(runs[index].time),
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
