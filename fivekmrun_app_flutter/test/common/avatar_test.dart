import 'package:fivekmrun_flutter/common/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
