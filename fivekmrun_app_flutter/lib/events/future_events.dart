import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (BuildContext context, int i) {
        final Event event = events[i];
        final bool isXL = event is XLEvent;
        return Card(
          child: ListTile(
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (isXL)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: XLBadge(),
                        ),
                      ListTileRow(text: event.location, icon: Icons.pin_drop),
                      ListTileRow(
                          text: dateFromat.format(event.date),
                          icon: Icons.calendar_today),
                      ListTileRow(
                        text: event.time,
                        icon: Icons.watch,
                      ),
                      if (event.title.isNotEmpty)
                        ListTileRow(
                            text: event.title,
                            icon: isXL ? Icons.terrain : Icons.info),
                      if (event is XLEvent &&
                          event.registrationLinks.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: event.registrationLinks
                                .map((link) => OutlinedButton(
                                      onPressed: () =>
                                          _openRegistrationLink(link.url),
                                      child: Text(link.label.isNotEmpty
                                          ? link.label
                                          : "Регистрация"),
                                    ))
                                .toList(),
                          ),
                        ),
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

  Future<void> _openRegistrationLink(String url) async {
    FirebaseAnalytics.instance.logEvent(name: "open_xlrun_registration_link");
    await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
  }
}

/// Marks an XLrun event card so it's visually distinguishable from regular
/// event days in the merged future-events list.
class XLBadge extends StatelessWidget {
  const XLBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: const Text(
        "XL",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12.0,
        ),
      ),
    );
  }
}
