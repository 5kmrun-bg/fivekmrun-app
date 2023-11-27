import 'package:fivekmrun_flutter/common/avatar.dart';
import 'package:fivekmrun_flutter/login/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets('should have circle avatar', (tester) async {
    final Key testKey = new Key('test-avatar');
    await mockNetworkImagesFor(
        () => tester.pumpWidget(Avatar(key: testKey, url: 'url')));

    expect(find.byKey(testKey), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('no avatar when url is empty', (tester) async {
    await mockNetworkImagesFor(
        () => tester.pumpWidget(Avatar(key: new Key('test-avatar'), url: '')));

    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('should have correct style', (tester) async {
    final Key testKey = new Key('test-avatar');
    await mockNetworkImagesFor(
        () => tester.pumpWidget(Avatar(key: testKey, url: 'url')));

    final padding = tester.widgetList<Padding>(find.byType(Padding));
    expect(padding.elementAt(0).padding,
        const EdgeInsets.only(top: 12.0, bottom: 12.0));
    expect(padding.elementAt(1).padding, EdgeInsets.all(2));
  });

  testGoldens('avatar snapshot', (tester) async {
    final appAccentColor = Color.fromRGBO(218, 3, 56, 1.0);
    await tester.pumpWidgetBuilder(Builder(
      builder: (BuildContext context) {
        return MaterialApp(
            theme: ThemeData(
              dividerColor: Colors.black12,
              textTheme: TextTheme(
                titleSmall:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                bodyLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                bodyMedium: TextStyle(fontSize: 10),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                return Colors.white;
              }))),
              textButtonTheme: TextButtonThemeData(style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  return Colors.white;
                }),
              )),
              appBarTheme: AppBarTheme(
                  backgroundColor: Color.fromRGBO(66, 66, 66, 1),
                  iconTheme: IconThemeData(color: Colors.white),
                  titleTextStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white)),
              colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: getColor(appAccentColor),
                  backgroundColor: Colors.black,
                  accentColor: appAccentColor,
                  errorColor: Colors.red,
                  brightness: Brightness.dark),
            ),
            home: Avatar(key: new Key('avatar-snapshot'), url: 'snapshot-url'));
      },
    ));

    await multiScreenGolden(tester, 'avatar', devices: [Device.phone]);
  });
}
