import 'dart:async';

import 'package:fivekmrun_flutter/login/login_with_username.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Fake that throws — the .then() block is never reached, so no Firebase calls
// are made. Only the .catchError() path runs, which calls setState.
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
    testWidgets('does not show error message on initial render', (tester) async {
      await tester.pumpWidget(_buildWidget(_ThrowingAuthResource()));

      expect(find.text(_errorText), findsNothing);
    });

    testWidgets('shows error message when authentication throws a generic exception',
        (tester) async {
      await tester.pumpWidget(_buildWidget(_ThrowingAuthResource()));

      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text(_errorText), findsOneWidget);
    });

    testWidgets('shows error message when authentication throws a SocketException',
        (tester) async {
      await tester.pumpWidget(
        _buildWidget(_ThrowingAuthResource(error: Exception('Connection refused'))),
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
        _buildWidget(_ThrowingAuthResource(error: TimeoutException('Request timed out'))),
      );

      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text(_errorText), findsOneWidget);
    });
  });
}
