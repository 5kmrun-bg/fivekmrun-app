import 'package:fivekmrun_flutter/profile.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter_test/flutter_test.dart';

Run _run({RunType runType = RunType.official, DateTime? date}) {
  return Run(
    runType: runType,
    date: date ?? DateTime(2024, 1, 1),
    timeInSeconds: 1200,
  );
}

void main() {
  group('runsForTrendChart', () {
    test('excludes XL runs but keeps official and selfie runs', () {
      final runs = [
        _run(runType: RunType.official),
        _run(runType: RunType.xl),
        _run(runType: RunType.selfie),
      ];

      final result = runsForTrendChart(runs);

      expect(result.map((r) => r.runType),
          [RunType.official, RunType.selfie]);
    });

    test('keeps only the first 30 non-XL runs', () {
      final runs = List.generate(35, (_) => _run(runType: RunType.official));

      final result = runsForTrendChart(runs);

      expect(result, hasLength(30));
    });

    test('an XL-only run list produces an empty trend chart list', () {
      final runs = [
        _run(runType: RunType.xl),
        _run(runType: RunType.xl),
      ];

      final result = runsForTrendChart(runs);

      expect(result, isEmpty);
    });
  });

  group('eventForBestTimeRun', () {
    test('points at the event the run belongs to', () {
      final run = Run(
        eventId: 1234,
        location: 'Южен Парк',
        date: DateTime(2024, 5, 4),
        timeInSeconds: 1004,
      );

      final event = eventForBestTimeRun(run)!;

      expect(event.id, 1234);
      expect(event.location, 'Южен Парк');
      expect(event.date, DateTime(2024, 5, 4));
      // A plain Event, so the results page uses the regular 5kmRun endpoint
      // rather than the XL or kids one.
      expect(event, isNot(isA<XLEvent>()));
      expect(event, isNot(isA<KidsEvent>()));
    });

    test('is null when the run has no event id', () {
      expect(eventForBestTimeRun(_run()), isNull);
    });
  });
}
