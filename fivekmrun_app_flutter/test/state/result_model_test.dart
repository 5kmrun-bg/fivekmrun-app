import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> selfieJson() => {
        "u_name": "Ivan",
        "u_surname": "Petrov",
        "s_uid": 42,
        "s_time": 1500,
        "s_total_elapsed_time": 1800,
        "s_finish_pos": 3,
        "u_runs_s": 60,
        "u_sex": "M",
        "s_type": 1,
        "s_start_location": "Park",
        "s_elevation_loss": 10,
        "s_elevation_gained": 20,
        "s_elevation_gained_total": 30,
        "s_map": "polyline",
        "s_distance": 5000,
        "s_total_distance": 6000,
        "s_start_date": "2021-06-15T08:00:00.000",
        "s_strava_link": "http://strava/1",
        "p_id": null,
        "u_daritel": 0,
      };

  Map<String, dynamic> officialJson() => {
        "u_name": "Ana",
        "u_surname": "Ivanova",
        "r_uid": 7,
        "r_time": 1200,
        "r_finish_pos": 1,
        "r_runs": 40,
        "u_help": 15,
        "u_sex": "F",
        "p_id": 99,
      };

  group('Result.fromJson (selfie)', () {
    test('parses identity and formatted time fields', () {
      final r = Result.fromJson(selfieJson());
      expect(r.name, "Ivan Petrov");
      expect(r.userId, 42);
      expect(r.time, "25:00");
      expect(r.totalTime, "30:00");
      expect(r.position, 3);
      expect(r.totalRuns, "60");
      expect(r.sex, "M");
      expect(r.pace, "05:00");
    });

    test('marks selfie, legioner status and elevation as doubles', () {
      final r = Result.fromJson(selfieJson());
      expect(r.isSelfie, isTrue);
      expect(r.isLegioner, isTrue); // u_runs_s >= 50
      expect(r.isDisqualified, isFalse); // s_type (1) <= 3
      expect(r.elevationLow, 10.0);
      expect(r.elevationHigh, 20.0);
      expect(r.elevationGainedTotal, 30.0);
      expect(r.stravaLink, "http://strava/1");
    });

    test('flags disqualification when s_type > 3', () {
      final json = selfieJson()..["s_type"] = 4;
      expect(Result.fromJson(json).isDisqualified, isTrue);
    });

    test('empty total time when elapsed is zero', () {
      final json = selfieJson()..["s_total_elapsed_time"] = 0;
      expect(Result.fromJson(json).totalTime, "");
    });
  });

  group('Result.fromEventJson (official)', () {
    test('parses fields and sums runs with helper count', () {
      final r = Result.fromEventJson(officialJson());
      expect(r.name, "Ana Ivanova");
      expect(r.userId, 7);
      expect(r.time, "20:00");
      expect(r.position, 1);
      expect(r.totalRuns, "55"); // 40 + 15
      expect(r.isSelfie, isFalse);
      expect(r.isPatreon, isTrue); // p_id != null
      expect(r.isLegioner, isTrue); // 55 >= 50
      expect(r.isAnonymous, isFalse);
    });

    test('treats r_uid == 0 as anonymous', () {
      final json = officialJson()..["r_uid"] = 0;
      expect(Result.fromEventJson(json).isAnonymous, isTrue);
    });

    test('defaults missing run counts to zero', () {
      final json = officialJson()
        ..remove("r_runs")
        ..remove("u_help");
      final r = Result.fromEventJson(json);
      expect(r.totalRuns, "0");
      expect(r.isLegioner, isFalse);
    });
  });

  group('Result.checkPatreonship', () {
    test('true when p_id present', () {
      expect(Result.checkPatreonship({"p_id": 5}), isTrue);
    });

    test('true when u_daritel is a future timestamp', () {
      final future =
          DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch;
      expect(Result.checkPatreonship({"p_id": null, "u_daritel": future ~/ 1000}),
          isTrue);
    });

    test('false when no patreon markers', () {
      expect(Result.checkPatreonship({"p_id": null, "u_daritel": 0}), isFalse);
    });
  });

  group('Result legioner helpers', () {
    test('getLegionerType uses runs + help >= 50', () {
      expect(Result.getLegionerType({"r_runs": 30, "u_help": 20}), isTrue);
      expect(Result.getLegionerType({"r_runs": 30, "u_help": 19}), isFalse);
      expect(Result.getLegionerType({}), isFalse);
    });

    test('getSelfieLegionerType uses u_runs_s >= 50', () {
      expect(Result.getSelfieLegionerType({"u_runs_s": 50}), isTrue);
      expect(Result.getSelfieLegionerType({"u_runs_s": 49}), isFalse);
    });
  });

  group('Result list parsers', () {
    test('listFromJson maps "runners"', () {
      final list = Result.listFromJson({
        "runners": [selfieJson(), selfieJson()]
      });
      expect(list, hasLength(2));
      expect(list.first.isSelfie, isTrue);
    });

    test('listFromEventJson maps the given list', () {
      final list = Result.listFromEventJson([officialJson()]);
      expect(list, hasLength(1));
      expect(list.first.name, "Ana Ivanova");
    });
  });
}
