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

  group('Event.fromXLJson', () {
    test('uses n_name as the title and a fixed XL image/location', () {
      final e = Event.fromXLJson({
        "e_id": 2,
        "n_name": "XL Route",
        "e_date": 1609459200,
        "e_time": "10:00",
      });
      expect(e.id, 2);
      expect(e.title, "XL Route");
      expect(e.location, "XLkm Run София");
      expect(e.imageUrl, contains("xl-run-thumbnail"));
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
