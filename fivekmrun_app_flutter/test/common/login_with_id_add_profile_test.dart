import 'package:fivekmrun_flutter/login/login_with_id.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../localized_app.dart';

class _FakeAuthResource extends AuthenticationResource {
  bool addProfileCalled = false;
  bool? lastMakeActive;

  @override
  Future<bool> authenticateWithUserId(int userId,
      {bool makeActive = true}) async {
    addProfileCalled = true;
    lastMakeActive = makeActive;
    return true;
  }
}

class _MaxProfilesAuthResource extends AuthenticationResource {
  @override
  Future<bool> authenticateWithUserId(int userId,
      {bool makeActive = true}) async {
    throw MaxProfilesReachedException();
  }
}

// Pushes LoginWithId(addingProfile: true) on a button tap and renders
// whatever it pops with — mirrors login_with_username_test.dart's harness.
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
                      Scaffold(body: LoginWithId(addingProfile: true)),
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

// The provider must wrap the whole app, not just `home` — see the identical
// note in login_with_username_test.dart.
Widget _buildAddProfileWidget(AuthenticationResource auth) {
  return ChangeNotifierProvider<AuthenticationResource>.value(
    value: auth,
    child: localizedApp(_AddProfileHarness()),
  );
}

const _maxProfilesText = 'Достигнат е максималният брой профили (5)';

void main() {
  group('LoginWithId addingProfile', () {
    testWidgets('adds an ID-only profile without switching, pops true',
        (tester) async {
      final auth = _FakeAuthResource();
      await tester.pumpWidget(_buildAddProfileWidget(auth));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '13731');
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      expect(auth.addProfileCalled, isTrue);
      expect(auth.lastMakeActive, isFalse);
      expect(find.byType(LoginWithId), findsNothing);
      expect(find.text('popped:true'), findsOneWidget);
    });

    testWidgets('shows a distinct message once the profile cap is reached',
        (tester) async {
      await tester
          .pumpWidget(_buildAddProfileWidget(_MaxProfilesAuthResource()));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '13731');
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      expect(find.text(_maxProfilesText), findsOneWidget);
      expect(find.byType(LoginWithId), findsOneWidget);
    });
  });
}
