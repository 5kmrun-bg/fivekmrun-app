import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat dateFromat = DateFormat(Constants.DATE_FORMAT);

class FutureEventsList extends StatelessWidget {
  const FutureEventsList({
    Key? key,
    required this.events,
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
                      ListTileRow(
                        text: event.time,
                        icon: Icons.watch,
                      ),
                      if (event.title.isNotEmpty)
                        ListTileRow(text: event.title, icon: Icons.info),
                    ],
                  ),
                ),
                if (event.imageUrl.isNotEmpty)
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
