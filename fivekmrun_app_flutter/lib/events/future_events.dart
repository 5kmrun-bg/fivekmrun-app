import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:fivekmrun_flutter/common/list_tile_row.dart';
import 'package:fivekmrun_flutter/common/pill.dart';
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
        final bool isKids = event is KidsEvent;
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (isXL)
                            const Padding(
                              padding: EdgeInsets.only(top: 4, bottom: 10),
                              child: XLBadge(),
                            ),
                          if (isKids)
                            const Padding(
                              padding: EdgeInsets.only(top: 4, bottom: 10),
                              child: KidsBadge(),
                            ),
                          ListTileRow(
                              text: event.location, icon: Icons.pin_drop),
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
                                icon: isXL
                                    ? Icons.terrain
                                    : isKids
                                        ? Icons.child_care
                                        : Icons.info),
                        ],
                      ),
                    ),
                    if (event.imageUrl.isNotEmpty)
                      SizedBox(
                        width: 120,
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
              if (event is XLEvent && event.registrationLinks.isNotEmpty)
                XLRegistrationSection(links: event.registrationLinks),
            ],
          ),
        );
      },
    );
  }
}

/// The XLrun registration strip shown at the bottom of a future-event card:
/// a full-bleed section marked off with a top divider and a "Регистрация"
/// header, with one button per distance tier. Each button opens that tier's
/// registration page in an in-app webview.
class XLRegistrationSection extends StatelessWidget {
  const XLRegistrationSection({Key? key, required this.links})
      : super(key: key);

  final List<XLRegistrationLink> links;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.secondary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        border: Border(
          top: BorderSide(color: accent.withOpacity(0.35)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.how_to_reg, size: 18, color: accent),
              const SizedBox(width: 6),
              Text(
                "Регистрация",
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              for (int j = 0; j < links.length; j++) ...<Widget>[
                if (j > 0) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openRegistrationLink(links[j].url),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accent),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: Text(
                      links[j].label.isNotEmpty
                          ? links[j].label
                          : "Регистрация",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
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
    return const Pill(
      label: "XL",
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }
}

/// Marks a KidsRun event card so it's visually distinguishable from regular
/// and XL event days in the merged future-events list.
class KidsBadge extends StatelessWidget {
  const KidsBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Pill(
      label: "Kids",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
}
