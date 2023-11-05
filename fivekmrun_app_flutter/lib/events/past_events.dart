import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat dateFromat = DateFormat(Constants.DATE_FORMAT);

class PastEventsList extends StatelessWidget {
  const PastEventsList({
    Key? key,
    required this.events,
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
                      if (events[i].title != "")
                        ListTileRow(text: events[i].title, icon: Icons.info),
                    ],
                  ),
                ),
                if (events[i].imageUrl != "")
                  Container(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Image.network(
                        events[i].imageUrl,
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
