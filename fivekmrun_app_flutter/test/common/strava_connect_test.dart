import 'package:fivekmrun_flutter/common/strava_connect.dart';
import 'package:fivekmrun_flutter/state/strava_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Stands in for the real StravaResource, whose isAuthenticated/authenticate
/// call out to a real strava_client (OAuth) and Firebase Crashlytics — same
/// pattern as _NoOpStravaResource in test/settings_page_test.dart.
class _FakeStravaResource extends StravaResource {
  _FakeStravaResource({bool initiallyAuthenticated = false})
      : _isAuthenticated = initiallyAuthenticated;

  bool _isAuthenticated;
  int authenticateCallCount = 0;
  int deAuthenticateCallCount = 0;

  @override
  Future<bool> isAuthenticated() async => _isAuthenticated;

  @override
  Future<bool> authenticate() async {
    authenticateCallCount++;
    // A real async gap, so the widget's loading state is observable between
    // pump() calls instead of resolving within the same microtask flush.
    await Future.delayed(const Duration(milliseconds: 10));
    _isAuthenticated = true;
    return true;
  }

  @override
  Future<void> deAuthenticate() async {
    deAuthenticateCallCount++;
    await Future.delayed(const Duration(milliseconds: 10));
    _isAuthenticated = false;
  }
}

Widget _harness(StravaResource strava) {
  return ChangeNotifierProvider<StravaResource>.value(
    value: strava,
    child: MaterialApp(home: Scaffold(body: StravaConnect())),
  );
}

void main() {
  group('StravaConnect', () {
    testWidgets('shows a spinner while isAuthenticated is resolving',
        (tester) async {
      await tester.pumpWidget(_harness(_FakeStravaResource()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows a connect button once isAuthenticated resolves false',
        (tester) async {
      await tester
          .pumpWidget(_harness(_FakeStravaResource(initiallyAuthenticated: false)));
      await tester.pumpAndSettle();

      expect(find.text('connect'), findsOneWidget);
      expect(find.text('disconnect'), findsNothing);
    });

    testWidgets('shows a disconnect button once isAuthenticated resolves true',
        (tester) async {
      await tester
          .pumpWidget(_harness(_FakeStravaResource(initiallyAuthenticated: true)));
      await tester.pumpAndSettle();

      expect(find.text('disconnect'), findsOneWidget);
      expect(find.text('connect'), findsNothing);
    });

    testWidgets('tapping connect calls authenticate and flips to disconnect',
        (tester) async {
      final strava = _FakeStravaResource(initiallyAuthenticated: false);
      await tester.pumpWidget(_harness(strava));
      await tester.pumpAndSettle();

      await tester.tap(find.text('connect'));
      await tester.pump(); // enters the loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(strava.authenticateCallCount, 1);
      expect(find.text('disconnect'), findsOneWidget);
    });

    testWidgets(
        'tapping disconnect calls deAuthenticate and flips to connect',
        (tester) async {
      final strava = _FakeStravaResource(initiallyAuthenticated: true);
      await tester.pumpWidget(_harness(strava));
      await tester.pumpAndSettle();

      // Unlike connect(), disconnect() fires strava.deAuthenticate() without
      // awaiting it before flipping isLoading back off, so the two setState
      // calls land in the same synchronous pass — there's no observable
      // loading frame here, just the immediate optimistic switch to
      // "connect".
      await tester.tap(find.text('disconnect'));
      await tester.pump();

      expect(find.text('connect'), findsOneWidget);
      expect(strava.deAuthenticateCallCount, 1);

      await tester.pumpAndSettle();
      expect(find.text('connect'), findsOneWidget);
    });

    testWidgets('tapping connect again while loading is a no-op',
        (tester) async {
      final strava = _FakeStravaResource(initiallyAuthenticated: false);
      await tester.pumpWidget(_harness(strava));
      await tester.pumpAndSettle();

      await tester.tap(find.text('connect'));
      await tester.pump(); // now loading; the button is gone
      expect(find.byType(ElevatedButton), findsNothing);

      await tester.pumpAndSettle();

      expect(strava.authenticateCallCount, 1);
    });
  });
}
