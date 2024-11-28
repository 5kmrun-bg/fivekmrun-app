import 'package:fivekmrun_flutter/common/results_list.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:fivekmrun_flutter/state/results_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class EventResultsPage extends StatefulWidget {
  EventResultsPage({Key? key}) : super(key: key);

  @override
  _EventResultsPageState createState() => _EventResultsPageState();
}

class _EventResultsPageState extends State<EventResultsPage> {
  ResultsResource results = ResultsResource();

  @override
  Widget build(BuildContext context) {
    Event event = ModalRoute.of(context)?.settings.arguments as Event;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.events_results_page_results)),
      body: FutureBuilder<List<Result>>(
        future: results.getAll(event.id),
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
              else
                return ResultsList(results: snapshot.data!);
          }
        },
      ),
    );
  }
}
