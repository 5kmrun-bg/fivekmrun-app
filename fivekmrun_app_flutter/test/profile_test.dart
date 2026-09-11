import 'package:fivekmrun_flutter/profile.dart';
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
}
