import 'package:fivekmrun_flutter/events/future_events.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets('regular event has no XL badge', (tester) async {
    final event = Event.fromJson({
      "e_id": 1,
      "e_title": "Race",
      "e_date": 1609459200,
      "e_time": "09:00",
      "n_name": "Sofia",
      "e_sponsor": "",
    });

    await mockNetworkImagesFor(() => tester.pumpWidget(MaterialApp(
          home: Scaffold(body: FutureEventsList(events: [event])),
        )));

    expect(find.byType(XLBadge), findsNothing);
    expect(find.byType(KidsBadge), findsNothing);
    expect(find.text("Sofia"), findsOneWidget);
    expect(find.text("Race"), findsOneWidget);
  });

  testWidgets('grouped XL event shows the XL badge, location and distances',
      (tester) async {
    final events = Event.listFromXLJson([
      {
        "e_id": 394,
        "n_name": "с. Кътина 4.8 км",
        "e_num": 5,
        "e_date": 1786827600,
        "e_time": "9:00",
      },
      {
        "e_id": 395,
        "n_name": "с. Кътина 9.6 км",
        "e_num": 5,
        "e_date": 1786827600,
        "e_time": "9:00",
      },
    ]);

    await mockNetworkImagesFor(() => tester.pumpWidget(MaterialApp(
          home: Scaffold(body: FutureEventsList(events: events)),
        )));

    expect(find.byType(XLBadge), findsOneWidget);
    expect(find.byType(KidsBadge), findsNothing);
    expect(find.text("с. Кътина"), findsOneWidget);
    expect(find.text("4.8 km · 9.6 km"), findsOneWidget);
  });

  testWidgets('kids event shows the Kids badge, location and title',
      (tester) async {
    final events = Event.listFromKidsJson([
      {
        "e_id": 520,
        "n_name": "Южен Парк Kids",
        "e_date": 1784926800,
        "e_time": "10:00",
        "e_title": "Детско бягане 2 км",
      },
    ]);

    await mockNetworkImagesFor(() => tester.pumpWidget(MaterialApp(
          home: Scaffold(body: FutureEventsList(events: events)),
        )));

    expect(find.byType(KidsBadge), findsOneWidget);
    expect(find.byType(XLBadge), findsNothing);
    expect(find.text("Южен Парк Kids"), findsOneWidget);
    expect(find.text("Детско бягане 2 км"), findsOneWidget);
  });
}
