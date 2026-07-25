import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/common/pill.dart';
import 'package:fivekmrun_flutter/common/refresh_helper.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserRunsPage extends StatelessWidget {
  const UserRunsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Твоите Бягания")),
        body: RefreshIndicator(
          onRefresh: () => refreshAllData(context),
          child: Consumer<RunsResource>(builder: (context, runsResource, child) {
            if (runsResource.loading) {
              return refreshableMessage(CircularProgressIndicator());
            } else if (runsResource.value == null ||
                runsResource.value?.length == 0) {
              return refreshableMessage(
                  Text("Все още не сте направили първото си бягане"));
            } else {
              return UserRunsList(runs: runsResource.value!);
            }
          }),
        ));
  }
}

class UserRunsList extends StatelessWidget {
  const UserRunsList({
    Key? key,
    required this.runs,
  }) : super(key: key);

  final List<Run> runs;

  @override
  Widget build(BuildContext context) {
    runs.sort((r1, r2) => r2.date?.compareTo(r1.date!) ?? 0);

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: runs.length,
      itemBuilder: (BuildContext context, int index) {
        final run = runs[index];

        return Card(
          child: ListTile(
            onTap: () => Navigator.of(context)
                .pushNamed("/run-details", arguments: run),
            trailing: RunTypePill(runType: run.runType),
            title: Column(
              children: <Widget>[
                if (run.runType != RunType.selfie)
                  ListTileRow(
                    icon: run.runType == RunType.xl
                        ? Icons.terrain
                        : run.runType == RunType.kids
                            ? Icons.child_care
                            : Icons.pin_drop,
                    text: run.location!,
                  ),
                ListTileRow(
                  icon: Icons.calendar_today,
                  text: run.displayDate,
                ),
                ListTileRow(
                  icon: Icons.timer,
                  text: run.time! + " мин",
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Labels a run card with its type. Replaces the previous per-type border
/// color, which read badly for XL against the app's dark theme — a solid
/// color chip is clearer than a thin colored outline.
class RunTypePill extends StatelessWidget {
  const RunTypePill({Key? key, required this.runType}) : super(key: key);

  final RunType runType;

  @override
  Widget build(BuildContext context) {
    switch (runType) {
      case RunType.official:
        return const OfficialPill();
      case RunType.selfie:
        return const SelfiePill();
      case RunType.xl:
        return const XLPill();
      case RunType.kids:
        return const KidsPill();
    }
  }
}
