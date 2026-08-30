import 'dart:async';
import 'dart:io';

import 'package:fivekmrun_flutter/login/login_with_username.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../localized_app.dart';

// Fake that throws, so only the .catchError() path runs. That path also
// reports to Crashlytics, which has no initialised Firebase app under test —
// the widget treats that reporting as best-effort, so the error UI still
// appears.
class _ThrowingAuthResource extends AuthenticationResource {
  final Object error;

  _ThrowingAuthResource({this.error = 'network error'});

  @override
  Future<bool> authenticate(String username, String password,
      {bool makeActive = true}) async {
    throw error;
  }
}

// localizedApp, not a bare MaterialApp: the widget reads its strings through
// AppLocalizations.of(context)!, which is null without the delegates.
Widget _buildWidget(AuthenticationResource auth) {
  return localizedApp(
    ChangeNotifierProvider<AuthenticationResource>.value(
      value: auth,
      child: const LoginWithUsername(),
    ),
  );
}

class _FakeAuthResource extends AuthenticationResource {
  bool addProfileCalled = false;
  bool? lastMakeActive;

  @override
  Future<bool> authenticate(String username, String password,
      {bool makeActive = true}) async {
    addProfileCalled = true;
    lastMakeActive = makeActive;
    return true;
  }
}

class _MaxProfilesAuthResource extends AuthenticationResource {
  @override
  Future<bool> authenticate(String username, String password,
      {bool makeActive = true}) async {
    throw MaxProfilesReachedException();
  }
}

// Pushes LoginWithUsername(addingProfile: true) on a button tap and renders
// whatever it pops with, so the addingProfile success path — pop(true)
// instead of pushNamedAndRemoveUntil("home") — is directly observable.
class _AddProfileHarness extends StatefulWidget {
  @override
  State<_AddProfileHarness> createState() => _AddProfileHarnessState();
}

class _AddProfileHarnessState extends State<_AddProfileHarness> {
  Object? _poppedValue;
  bool _hasPopped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (_hasPopped) Text('popped:$_poppedValue'),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<Object?>(
                MaterialPageRoute(
                  builder: (_) =>
                      const Scaffold(body: LoginWithUsername(addingProfile: true)),
                ),
              );
              setState(() {
                _hasPopped = true;
                _poppedValue = result;
              });
            },
            child: const Text('open'),
          ),
        ],
      ),
    );
  }
}

// The provider must wrap the whole `localizedApp` (MaterialApp), not just
// its `home` route's content — a route pushed via Navigator.push lives in
// the Overlay as a sibling of `home`, not a descendant of it, so a provider
// scoped inside `home` would be invisible to LoginWithUsername once pushed.
Widget _buildAddProfileWidget(AuthenticationResource auth) {
  return ChangeNotifierProvider<AuthenticationResource>.value(
    value: auth,
    child: localizedApp(_AddProfileHarness()),
  );
}

// The Bulgarian text, since localizedApp defaults to bg.
const _errorText = 'Грешно потребителско име или парола';
const _maxProfilesText = 'Достигнат е максималният брой профили (5)';

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

  group('LoginWithUsername addingProfile', () {
    testWidgets('adds without disturbing the active profile, pops true',
        (tester) async {
      final auth = _FakeAuthResource();
      await tester.pumpWidget(_buildAddProfileWidget(auth));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'kid@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      expect(auth.addProfileCalled, isTrue);
      expect(auth.lastMakeActive, isFalse);
      expect(find.byType(LoginWithUsername), findsNothing);
      expect(find.text('popped:true'), findsOneWidget);
    });

    testWidgets('shows a distinct message once the profile cap is reached',
        (tester) async {
      await tester
          .pumpWidget(_buildAddProfileWidget(_MaxProfilesAuthResource()));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'kid@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      expect(find.text(_maxProfilesText), findsOneWidget);
      // Still on the add-profile screen — nothing was popped.
      expect(find.byType(LoginWithUsername), findsOneWidget);
    });
  });
}
