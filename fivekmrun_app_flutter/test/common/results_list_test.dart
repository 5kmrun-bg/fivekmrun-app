import 'package:fivekmrun_flutter/common/results_list.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localized_app.dart';

Result _result({
  required String name,
  required int userId,
  bool isAnonymous = false,
  String mapPolyline = "",
}) {
  return Result(
    name: name,
    time: "00:20:00",
    position: 1,
    totalRuns: "1",
    sex: "m",
    userId: userId,
    isAnonymous: isAnonymous,
    mapPolyline: mapPolyline,
  );
}

Widget _harness(List<Result> results, AuthenticationResource authRes) {
  return ChangeNotifierProvider<AuthenticationResource>.value(
    value: authRes,
    child: localizedApp(SizedBox(
      height: 600,
      child: ResultsList(results: results),
    )),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('filtering', () {
    testWidgets('shows every result before any search text is entered',
        (tester) async {
      final results = <Result>[
        _result(name: "Ivan Ivanov", userId: 111),
        _result(name: "Georgi Georgiev", userId: 222),
      ];
      final authRes = AuthenticationResource();

      await tester.pumpWidget(_harness(results, authRes));
      await tester.pumpAndSettle();

      expect(find.text("Ivan Ivanov"), findsOneWidget);
      expect(find.text("Georgi Georgiev"), findsOneWidget);
    });

    testWidgets('filters by a case-insensitive substring of the name',
        (tester) async {
      final results = <Result>[
        _result(name: "Ivan Ivanov", userId: 111),
        _result(name: "Georgi Georgiev", userId: 222),
      ];
      final authRes = AuthenticationResource();

      await tester.pumpWidget(_harness(results, authRes));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), "ivan");
      await tester.pumpAndSettle();

      expect(find.text("Ivan Ivanov"), findsOneWidget);
      expect(find.text("Georgi Georgiev"), findsNothing);
    });

    // The lowercase case above only pins that the *name* is lowercased. This
    // pins the other half — that the *query* is too. It is the half real
    // users hit: mobile keyboards capitalise the first letter, so "Ivan" is
    // what actually gets typed.
    testWidgets('filters when the typed query is capitalised',
        (tester) async {
      final results = <Result>[
        _result(name: "Ivan Ivanov", userId: 111),
        _result(name: "Georgi Georgiev", userId: 222),
      ];
      final authRes = AuthenticationResource();

      await tester.pumpWidget(_harness(results, authRes));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), "IVAN");
      await tester.pumpAndSettle();

      expect(find.text("Ivan Ivanov"), findsOneWidget);
      expect(find.text("Georgi Georgiev"), findsNothing);
    });

    testWidgets('filters by an exact userId match, not a substring',
        (tester) async {
      final results = <Result>[
        _result(name: "Ivan Ivanov", userId: 111),
        _result(name: "Georgi Georgiev", userId: 1110),
      ];
      final authRes = AuthenticationResource();

      await tester.pumpWidget(_harness(results, authRes));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), "111");
      await tester.pumpAndSettle();

      // "111" matches result 111's userId exactly, and also matches
      // "Georgi Georgiev" not at all by name — but userId 1110 does not
      // equal the trimmed search text "111", so only the exact id matches.
      expect(find.text("Ivan Ivanov"), findsOneWidget);
      expect(find.text("Georgi Georgiev"), findsNothing);
    });

    testWidgets('clearing the search box restores every result',
        (tester) async {
      final results = <Result>[
        _result(name: "Ivan Ivanov", userId: 111),
        _result(name: "Georgi Georgiev", userId: 222),
      ];
      final authRes = AuthenticationResource();

      await tester.pumpWidget(_harness(results, authRes));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), "ivan");
      await tester.pumpAndSettle();
      expect(find.text("Georgi Georgiev"), findsNothing);

      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pumpAndSettle();

      expect(find.text("Ivan Ivanov"), findsOneWidget);
      expect(find.text("Georgi Georgiev"), findsOneWidget);
    });

    testWidgets('shows the no-results message when nothing matches',
        (tester) async {
      final results = <Result>[
        _result(name: "Ivan Ivanov", userId: 111),
      ];
      final authRes = AuthenticationResource();

      await tester.pumpWidget(_harness(results, authRes));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), "no such runner");
      await tester.pumpAndSettle();

      expect(find.text("Ivan Ivanov"), findsNothing);
      expect(find.text("Няма резултати"), findsOneWidget);
    });

    testWidgets('re-filters against the active search text when the results '
        'list is replaced', (tester) async {
      final initialResults = <Result>[
        _result(name: "Ivan Ivanov", userId: 111),
      ];
      final authRes = AuthenticationResource();

      await tester.pumpWidget(_harness(initialResults, authRes));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), "petar");
      await tester.pumpAndSettle();
      expect(find.text("Ivan Ivanov"), findsNothing);

      final updatedResults = <Result>[
        _result(name: "Ivan Ivanov", userId: 111),
        _result(name: "Petar Petrov", userId: 333),
      ];
      await tester.pumpWidget(_harness(updatedResults, authRes));
      await tester.pumpAndSettle();

      // didUpdateWidget re-runs the filter against the search text that was
      // already typed, rather than resetting it.
      expect(find.text("Petar Petrov"), findsOneWidget);
      expect(find.text("Ivan Ivanov"), findsNothing);
    });
  });

  group('locate-me button', () {
    testWidgets(
        'is hidden when none of the results belong to the active profile',
        (tester) async {
      final results = <Result>[
        _result(name: "Ivan Ivanov", userId: 111),
      ];
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(999);

      await tester.pumpWidget(_harness(results, authRes));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_searching), findsNothing);
    });

    testWidgets('is shown when the active profile has a result in the list',
        (tester) async {
      final results = <Result>[
        _result(name: "Ivan Ivanov", userId: 111),
      ];
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(111);

      await tester.pumpWidget(_harness(results, authRes));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_searching), findsOneWidget);
    });
  });

  group('anonymous results', () {
    testWidgets('shows the localized "anonymous" label instead of the name',
        (tester) async {
      final results = <Result>[
        _result(name: "", userId: 0, isAnonymous: true),
      ];
      final authRes = AuthenticationResource();

      await tester.pumpWidget(_harness(results, authRes));
      await tester.pumpAndSettle();

      expect(find.text("Анонимен"), findsOneWidget);
    });
  });
}
