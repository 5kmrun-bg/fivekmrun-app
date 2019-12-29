import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/state/events_resource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final DateFormat dateFromat = DateFormat("dd.MM.yyyy");

class FutureEventsPage extends StatelessWidget {
  const FutureEventsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Предстоящи Събития")),
      body: Consumer<FutureEventsResource>(
          builder: (context, eventsResource, child) {
        return FutureBuilder(
          future: eventsResource.load(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Center(child: CircularProgressIndicator());
                break;
              case ConnectionState.done:
                if (snapshot.hasError)
                  return Text(
                    'Error:\n\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  );
                else
                  return FutureEventsList(events: snapshot.data);
            }
          },
        );
      }),
    );
  }
}

class FutureEventsList extends StatelessWidget {
  const FutureEventsList({
    Key key,
    @required this.events,
  }) : super(key: key);

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (BuildContext context, int i) {
        final Event event = events[i];
        return Card(
          child: ListTile(
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTileRow(text: event.location, icon: Icons.pin_drop),
                      ListTileRow(
                          text: dateFromat.format(event.date),
                          icon: Icons.calendar_today),
                      ListTileRow(text: event.title, icon: Icons.info),
                    ],
                  ),
                ),
                Container(
                  width: 120,
                  child: Image.network(
                    event.imageUrl,
                    fit: BoxFit.fitWidth,
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
