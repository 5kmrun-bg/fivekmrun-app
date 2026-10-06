import 'package:fivekmrun_flutter/common/pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(theme: theme, home: Scaffold(body: Center(child: child)));
}

/// The pill's background lives on its `Container` decoration.
Color? _background(WidgetTester tester) {
  final container = tester.widget<Container>(
      find.descendant(of: find.byType(Pill), matching: find.byType(Container)));
  return (container.decoration as BoxDecoration).color;
}

TextStyle? _textStyle(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style;

void main() {
  group('Pill variants', () {
    final cases = <String, (Widget, String, Color, Color)>{
      'XLPill': (const XLPill(), 'XL', Colors.blue, Colors.white),
      'KidsPill': (const KidsPill(), 'Kids', Colors.green, Colors.white),
      'OfficialPill':
          (const OfficialPill(), '5kmrun', Colors.white, Colors.black87),
    };

    cases.forEach((name, c) {
      final (widget, label, background, textColor) = c;

      testWidgets('$name shows "$label" with its colours', (tester) async {
        await tester.pumpWidget(_app(widget));

        expect(find.text(label), findsOneWidget);
        expect(_background(tester), background);
        expect(_textStyle(tester, label)?.color, textColor);
      });
    });

    testWidgets('SelfiePill uses the theme secondary colour', (tester) async {
      await tester.pumpWidget(_app(
        const SelfiePill(),
        theme: ThemeData(
            colorScheme: const ColorScheme.dark(secondary: Colors.orange)),
      ));

      expect(find.text('Selfie'), findsOneWidget);
      expect(_background(tester), Colors.orange);
      expect(_textStyle(tester, 'Selfie')?.color, Colors.white);
    });
  });

  group('Pill', () {
    testWidgets('uses the given label and colours, in bold', (tester) async {
      await tester.pumpWidget(_app(const Pill(
        label: 'Custom',
        backgroundColor: Colors.purple,
        textColor: Colors.yellow,
      )));

      expect(find.text('Custom'), findsOneWidget);
      expect(_background(tester), Colors.purple);
      final style = _textStyle(tester, 'Custom');
      expect(style?.color, Colors.yellow);
      expect(style?.fontWeight, FontWeight.bold);
    });
  });
}
