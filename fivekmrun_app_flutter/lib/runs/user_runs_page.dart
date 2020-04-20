import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserRunsPage extends StatelessWidget {
  const UserRunsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Твоите Бягания")),
        body: Consumer<RunsResource>(builder: (context, runsResource, child) {
          return UserRunsList(runs: runsResource.value);
        }));
  }
}

class UserRunsList extends StatelessWidget {
  const UserRunsList({
    Key key,
    @required this.runs,
  }) : super(key: key);

  final List<Run> runs;

  @override
  Widget build(BuildContext context) {
    if (runs == null || runs.length <= 0) {
      return Text("Все още не сте направили първото си официално бягане");
    }

    runs.sort((r1, r2) => r2.date.compareTo(r1.date));

    return ListView.builder(
      itemCount: runs.length,
      itemBuilder: (BuildContext context, int index) {
        final run = runs[index];
        return Card(
          child: ListTile(
            onTap: () =>
                Navigator.of(context).pushNamed("/run-details", arguments: run),
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
  }
}
