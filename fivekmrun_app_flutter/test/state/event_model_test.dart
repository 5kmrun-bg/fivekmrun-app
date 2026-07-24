import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Event.fromJson', () {
    test('parses a standard event', () {
      final e = Event.fromJson({
        "e_id": 1,
        "e_title": "Race",
        "e_date": 1609459200, // seconds
        "e_time": "09:00",
        "n_name": "Sofia",
        "e_sponsor": "logo.png",
      });
      expect(e.id, 1);
      expect(e.title, "Race");
      expect(e.time, "09:00");
      expect(e.location, "Sofia");
      expect(e.imageUrl, "logo.png");
      expect(e.detailsUrl, "");
      expect(e.date, DateTime.fromMillisecondsSinceEpoch(1609459200 * 1000));
    });
  });

  group('Event.listFromXLJson', () {
    test('groups rows sharing e_num + e_date into a single XLEvent', () {
      final events = Event.listFromXLJson([
        {
          "e_id": 394,
          "n_name": "с. Кътина 4.8 км",
          "e_num": 5,
          "e_date": 1786827600,
          "e_time": "9:00",
          "e_title": "Къса дистанция",
        },
        {
          "e_id": 395,
          "n_name": "с. Кътина 9.6 км",
          "e_num": 5,
          "e_date": 1786827600,
          "e_time": "9:00",
          "e_title": "Средна дистанция",
        },
        {
          "e_id": 396,
          "n_name": "с. Кътина 14.4 км",
          "e_num": 5,
          "e_date": 1786827600,
          "e_time": "9:00",
          "e_title": "XL дистанция",
        },
      ]);

      expect(events, hasLength(1));
      final e = events.single as XLEvent;
      expect(e.location, "с. Кътина");
      expect(e.distances, ["4.8 km", "9.6 km", "14.4 km"]);
      expect(e.title, "4.8 km · 9.6 km · 14.4 km");
      expect(e.time, "9:00");
      expect(e.imageUrl, contains("xl-run-thumbnail"));
      expect(e.date, DateTime.fromMillisecondsSinceEpoch(1786827600 * 1000));
    });

    test('keeps separate locations/days as separate groups', () {
      final events = Event.listFromXLJson([
        {
          "e_id": 1,
          "n_name": "с. Кътина 4.8 км",
          "e_num": 5,
          "e_date": 1786827600,
          "e_time": "9:00",
        },
        {
          "e_id": 2,
          "n_name": "гр. Своге 6 км",
          "e_num": 6,
          "e_date": 1789419600,
          "e_time": "9:00",
        },
      ]);

      expect(events, hasLength(2));
      expect((events[0] as XLEvent).location, "с. Кътина");
      expect((events[1] as XLEvent).location, "гр. Своге");
    });

    test('falls back to e_id as the grouping key when e_num is missing', () {
      final events = Event.listFromXLJson([
        {
          "e_id": 1,
          "n_name": "XL Route",
          "e_date": 1609459200,
          "e_time": "10:00",
        },
      ]);

      expect(events, hasLength(1));
      final e = events.single as XLEvent;
      expect(e.distances, ["XL Route"]);
    });
  });

  group('Event.fromKidsJson', () {
    test('uses e_title as title and n_name as location', () {
      final e = Event.fromKidsJson({
        "e_id": 3,
        "e_title": "Kids Race",
        "n_name": "Playground",
        "e_date": 1609459200,
        "e_time": "11:00",
      });
      expect(e.id, 3);
      expect(e.title, "Kids Race");
      expect(e.location, "Playground");
      expect(e.imageUrl, contains("kids-run"));
    });
  });

  group('Event list parsers', () {
    final raw = [
      {
        "e_id": 1,
        "e_title": "Race",
        "e_date": 1609459200,
        "e_time": "09:00",
        "n_name": "Sofia",
        "e_sponsor": "logo.png",
      }
    ];

    test('listFromJson maps every entry', () {
      expect(Event.listFromJson(raw), hasLength(1));
      expect(Event.listFromJson(raw).first.title, "Race");
    });

    test('listFromXLJson and listFromKidsJson map every entry', () {
      expect(Event.listFromXLJson(raw), hasLength(1));
      expect(Event.listFromKidsJson(raw), hasLength(1));
    });
  });
}
