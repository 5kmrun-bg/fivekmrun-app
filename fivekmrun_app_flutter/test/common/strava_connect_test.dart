import 'package:fivekmrun_flutter/common/strava_connect.dart';
import 'package:fivekmrun_flutter/state/strava_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Stands in for the real StravaResource, whose isAuthenticated/authenticate
/// call out to a real strava_client (OAuth) and Firebase Crashlytics — same
/// pattern as _NoOpStravaResource in test/settings_page_test.dart.
class _FakeStravaResource extends StravaResource {
  _FakeStravaResource({
    bool initiallyAuthenticated = false,
    this.isAuthenticatedDelay = Duration.zero,
  }) : _isAuthenticated = initiallyAuthenticated;

  /// Widens the async gap in [isAuthenticated] so a test can dispose the
  /// widget while the call is still in flight. The real resource talks to an
  /// OAuth client, so that window is far wider in production than in tests.
  final Duration isAuthenticatedDelay;

  bool _isAuthenticated;
  int authenticateCallCount = 0;
  int deAuthenticateCallCount = 0;

  @override
  Future<bool> isAuthenticated() async {
    if (isAuthenticatedDelay > Duration.zero) {
      await Future.delayed(isAuthenticatedDelay);
    }
    return _isAuthenticated;
  }

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

      // deAuthenticate() is awaited, so there is a real loading frame before
      // the flip — the button must not claim "connect" until the
      // deauthorization has actually completed.
      await tester.tap(find.text('disconnect'));
      await tester.pump();

      expect(find.byType(ElevatedButton), findsNothing);
      expect(strava.deAuthenticateCallCount, 1);

      await tester.pumpAndSettle();
      expect(find.text('connect'), findsOneWidget);
    });

    // Named for what this actually asserts: while the call is in flight the
    // button is replaced by the spinner, so a second tap is unreachable
    // through the UI. It does not exercise connect()'s isLoading guard.
    testWidgets('hides the button while authenticate is in flight',
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

    // Each of the three async paths below calls setState after an await.
    // Backing out of Settings (which hosts this widget) while the call is
    // still in flight tears the State down first, so setState lands on a
    // defunct State and throws unless guarded by `mounted`.
    testWidgets('does not setState when disposed during isAuthenticated',
        (tester) async {
      final strava = _FakeStravaResource(
          isAuthenticatedDelay: const Duration(milliseconds: 50));
      await tester.pumpWidget(_harness(strava));
      await tester.pump(); // mounted; isAuthenticated still pending

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not setState when disposed during authenticate',
        (tester) async {
      final strava = _FakeStravaResource(initiallyAuthenticated: false);
      await tester.pumpWidget(_harness(strava));
      await tester.pumpAndSettle();

      await tester.tap(find.text('connect'));
      await tester.pump(); // authenticate in flight

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not setState when disposed during deAuthenticate',
        (tester) async {
      final strava = _FakeStravaResource(initiallyAuthenticated: true);
      await tester.pumpWidget(_harness(strava));
      await tester.pumpAndSettle();

      await tester.tap(find.text('disconnect'));
      await tester.pump(); // deAuthenticate in flight

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });
  });
}
