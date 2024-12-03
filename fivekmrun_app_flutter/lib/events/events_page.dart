import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:fivekmrun_flutter/common/select_button.dart';
import 'package:fivekmrun_flutter/events/future_events.dart';
import 'package:fivekmrun_flutter/events/past_events.dart';
import 'package:fivekmrun_flutter/state/events_resource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final DateFormat dateFromat = DateFormat(Constants.DATE_FORMAT);

class EventsPage extends StatefulWidget {
  EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPage createState() => _EventsPage();
}

class _EventsPage extends State<EventsPage> {
  bool futureEventSelected = true;

  toggleEvents() {
    setState(() {
      this.futureEventSelected = !this.futureEventSelected;
    });
  }

  Widget _buildEvents() {
    if (!this.futureEventSelected) {
      return Consumer<PastEventsResource>(
        builder: (context, eventsResource, child) {
          if (eventsResource.loading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return PastEventsList(events: eventsResource.value);
          }
        },
      );
    }

    return Consumer<AllFutureEventsResource>(
      builder: (context, eventsResource, child) {
        if (eventsResource.loading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return FutureEventsList(events: eventsResource.value);
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.events_page_events)),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SelectButton(
                  text: AppLocalizations.of(context)!.events_page_past_events,
                  onPressed: this.toggleEvents,
                  selected: !this.futureEventSelected,
                ),
                SelectButton(
                  text: AppLocalizations.of(context)!.events_page_upcoming_events,
                  onPressed: this.toggleEvents,
                  selected: this.futureEventSelected,
                ),
              ],
            ),
            Expanded(
              child: this._buildEvents()
            )
          ]
        )
      )
    );
  }
}
