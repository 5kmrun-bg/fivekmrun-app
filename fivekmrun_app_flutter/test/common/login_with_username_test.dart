import 'dart:async';
import 'dart:io';

import 'package:fivekmrun_flutter/login/login_with_username.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Fake that throws, so only the .catchError() path runs. That path also
// reports to Crashlytics, which has no initialised Firebase app under test —
// the widget treats that reporting as best-effort, so the error UI still
// appears.
class _ThrowingAuthResource extends AuthenticationResource {
  final Object error;

  _ThrowingAuthResource({this.error = 'network error'});

  @override
  Future<bool> authenticate(String username, String password) async {
    throw error;
  }
}

Widget _buildWidget(AuthenticationResource auth) {
  return MaterialApp(
    home: Scaffold(
      body: ChangeNotifierProvider<AuthenticationResource>.value(
        value: auth,
        child: LoginWithUsername(),
      ),
    ),
  );
}

const _errorText = 'Грешно потребителско име или парола';

void main() {
  group('LoginWithUsername', () {
    testWidgets('does not show error message on initial render',
        (tester) async {
      await tester.pumpWidget(_buildWidget(_ThrowingAuthResource()));

      expect(find.text(_errorText), findsNothing);
    });

    testWidgets(
        'shows error message when authentication throws a generic exception',
        (tester) async {
      await tester.pumpWidget(_buildWidget(_ThrowingAuthResource()));

      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text(_errorText), findsOneWidget);
    });

    // What a dead network actually produces: HttpClient.postUrl throws
    // SocketException for a failed DNS lookup, a refused connection and
    // blackholed traffic alike.
    testWidgets(
        'shows error message when authentication throws a SocketException',
        (tester) async {
      await tester.pumpWidget(
        _buildWidget(_ThrowingAuthResource(
            error: const SocketException('Failed host lookup: 5kmrun.bg'))),
      );

      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text(_errorText), findsOneWidget);
    });

    testWidgets('shows error message when authentication throws a timeout',
        (tester) async {
      await tester.pumpWidget(
        _buildWidget(_ThrowingAuthResource(
            error: TimeoutException('Request timed out'))),
      );

      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text(_errorText), findsOneWidget);
    });
  });
}
