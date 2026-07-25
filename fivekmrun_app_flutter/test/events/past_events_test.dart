import 'package:fivekmrun_flutter/common/pill.dart';
import 'package:fivekmrun_flutter/events/past_events.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets('regular past event has no XL badge', (tester) async {
    final event = Event.fromJson({
      "e_id": 1,
      "e_title": "Race",
      "e_date": 1609459200,
      "e_time": "09:00",
      "n_name": "Sofia",
      "e_sponsor": "",
    });

    await mockNetworkImagesFor(() => tester.pumpWidget(MaterialApp(
          home: Scaffold(body: PastEventsList(events: [event])),
        )));

    expect(find.byType(XLPill), findsNothing);
    expect(find.text("Sofia"), findsOneWidget);
  });

  testWidgets(
      'XLrun past results show the XL badge and real mileage, ungrouped',
      (tester) async {
    final events = Event.listFromXLPastJson([
      {
        "e_id": 393,
        "n_name": "Сеславци 15.2 км",
        "e_date": 1783803600,
        "e_time": "10:00",
      },
      {
        "e_id": 394,
        "n_name": "Сеславци 7.6 км",
        "e_date": 1783803600,
        "e_time": "10:00",
      },
    ]);

    await mockNetworkImagesFor(() => tester.pumpWidget(MaterialApp(
          home: Scaffold(body: PastEventsList(events: events)),
        )));

    // Same day/location, but rendered as two separate tappable items, each
    // with its own badge and mileage — not merged into one grouped card.
    expect(find.byType(XLPill), findsNWidgets(2));
    expect(find.text("15.2 km"), findsOneWidget);
    expect(find.text("7.6 km"), findsOneWidget);
  });
}
