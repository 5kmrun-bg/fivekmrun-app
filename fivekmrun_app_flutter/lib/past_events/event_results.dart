import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:fivekmrun_flutter/state/results_resource.dart';
import 'package:flutter/material.dart';

class EventResults extends StatefulWidget {
  EventResults({Key key}) : super(key: key);

  @override
  _EventResultsState createState() => _EventResultsState();
}

class _EventResultsState extends State<EventResults> {
  ResultsResource results = ResultsResource();

  @override
  Widget build(BuildContext context) {
    Event event = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(title: Text("Резултати")),
      body: FutureBuilder<List<Result>>(
        future: results.load(id: event.id),
        initialData: [],
        builder: (BuildContext context, AsyncSnapshot<List<Result>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError)
                return Text(
                  'Error:\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                );
              return ResultsList(results: snapshot.data);
          }
        },
      ),
    );
  }
}

class ResultsList extends StatelessWidget {
  final List<Result> results;
  const ResultsList({Key key, this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        final res = results[index];
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;
        final labelStyle = theme.textTheme.body1;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        res.position.toString(),
                        style: textTheme.display2
                            .copyWith(color: theme.accentColor),
                      ),
                      Text("място", style: labelStyle),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTileRow(
                        icon: Icons.person,
                        text: res.name,
                      ),
                      ListTileRow(
                        icon: Icons.timer,
                        text: res.time,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
