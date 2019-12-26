import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/state/events_resource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final DateFormat dateFromat = DateFormat("dd.MM.yyyy");

class FutureEventsList extends StatelessWidget {
  const FutureEventsList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FutureEventsResource>(
        builder: (context, eventsResource, child) {
      final events = eventsResource.value;
      if (events != null) {
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (BuildContext context, int i) {
            return Card(
              child: Row(
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
                        ListTileRow(text: events[i].title, icon: Icons.info),
                      ],
                    ),
                  ),
                  Container(
                    width: 120,
                    child: Image.network(events[i].imageUrl, fit: BoxFit.fitWidth,),
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
