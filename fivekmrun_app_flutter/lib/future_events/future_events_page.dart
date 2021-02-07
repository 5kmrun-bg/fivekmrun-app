import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/state/events_resource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final DateFormat dateFromat = DateFormat(Constants.DATE_FORMAT);

class FutureEventsPage extends StatelessWidget {
  const FutureEventsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Предстоящи Събития")),
      body: Consumer<FutureEventsResource>(
          builder: (context, eventsResource, child) {
        if (eventsResource.loading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return FutureEventsList(events: eventsResource.value);
        }
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
      itemCount: events?.length ?? 0,
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
                  decoration: new BoxDecoration(
                      borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(10.0),
                    topRight: const Radius.circular(10.0),
                  )),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Image.network(
                      event.imageUrl,
                      fit: BoxFit.fitWidth,
                    ),
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
