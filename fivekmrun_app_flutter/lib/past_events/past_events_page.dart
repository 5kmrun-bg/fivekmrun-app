import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/state/events_resource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final DateFormat dateFromat = DateFormat(Constants.DATE_FORMAT);

class PastEventsPage extends StatelessWidget {
  const PastEventsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Минали Събития")),
      body: Consumer<PastEventsResource>(
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
                    return PastEventsList(events: snapshot.data);
              }
            },
          );
        },
      ),
    );
  }
}

class PastEventsList extends StatelessWidget {
  const PastEventsList({
    Key key,
    @required this.events,
  }) : super(key: key);

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (BuildContext context, int i) {
        return Card(
          child: ListTile(
            onTap: () => Navigator.of(context).pushNamed(
              "/event-results",
              arguments: events[i],
            ),
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTileRow(
                          text: events[i].location, icon: Icons.pin_drop),
                      ListTileRow(
                          text: dateFromat.format(events[i].date),
                          icon: Icons.calendar_today),
                      if (events[i].title != null && events[i].title != "")
                        ListTileRow(text: events[i].title, icon: Icons.info),
                    ],
                  ),
                ),
                Container(
                  width: 120,
                  child: Image.network(
                    events[i].imageUrl,
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
