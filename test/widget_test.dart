import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:digital_pet/main.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const DigitalPetApp());
    await tester.pumpAndSettle();
  }

  Future<void> tapButton(WidgetTester tester, String text) async {
    final finder = find.text(text);

    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();

    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('Digital Pet Integrated UI', () {
    testWidgets('displays initial integrated pet state', (tester) async {
      await pumpApp(tester);

      expect(find.text('Digital Pet'), findsOneWidget);
      expect(find.text('My Pet'), findsOneWidget);
      expect(find.text('Mood: Neutral'), findsOneWidget);
      expect(find.text('Happiness: 50'), findsOneWidget);
      expect(find.text('Hunger: 50'), findsOneWidget);
      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('Play increases happiness and hunger', (tester) async {
      await pumpApp(tester);

      await tapButton(tester, 'Play');

      expect(find.text('Happiness: 65'), findsOneWidget);
      expect(find.text('Hunger: 55'), findsOneWidget);
      expect(find.text('Mood: Neutral'), findsOneWidget);
    });

    testWidgets('pet becomes happy above 70 happiness', (tester) async {
      await pumpApp(tester);

      await tapButton(tester, 'Play');
      await tapButton(tester, 'Play');

      expect(find.text('Happiness: 80'), findsOneWidget);
      expect(find.text('Hunger: 60'), findsOneWidget);
      expect(find.text('Mood: Happy'), findsOneWidget);
    });

    testWidgets('Feed decreases hunger and increases happiness', (
      tester,
    ) async {
      await pumpApp(tester);

      await tapButton(tester, 'Feed');

      expect(find.text('Hunger: 40'), findsOneWidget);
      expect(find.text('Happiness: 60'), findsOneWidget);
      expect(find.text('Mood: Neutral'), findsOneWidget);
    });

    testWidgets('pet name can be changed', (tester) async {
      await pumpApp(tester);

      final textField = find.byType(TextField);

      await tester.ensureVisible(textField);
      await tester.enterText(textField, 'Pip');
      await tester.pumpAndSettle();

      await tapButton(tester, 'Confirm Name');

      expect(find.text('Pip'), findsOneWidget);
      expect(find.bySemanticsLabel('Pip is currently Neutral'), findsOneWidget);
    });

    testWidgets('Reset restores initial integrated state', (tester) async {
      await pumpApp(tester);

      await tapButton(tester, 'Play');

      expect(find.text('Happiness: 65'), findsOneWidget);
      expect(find.text('Hunger: 55'), findsOneWidget);

      await tapButton(tester, 'Reset');

      expect(find.text('My Pet'), findsOneWidget);
      expect(find.text('Happiness: 50'), findsOneWidget);
      expect(find.text('Hunger: 50'), findsOneWidget);
      expect(find.text('Mood: Neutral'), findsOneWidget);
    });

    testWidgets('pet exposes mood semantics', (tester) async {
      final semantics = tester.ensureSemantics();

      await pumpApp(tester);

      expect(
        find.bySemanticsLabel('My Pet is currently Neutral'),
        findsOneWidget,
      );

      semantics.dispose();
    });

    testWidgets('meters expose accessible values', (tester) async {
      await pumpApp(tester);

      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );

      expect(
        semanticsWidgets.any(
          (widget) => widget.properties.label == 'Happiness 50 out of 100',
        ),
        isTrue,
      );

      expect(
        semanticsWidgets.any(
          (widget) => widget.properties.label == 'Hunger 50 out of 100',
        ),
        isTrue,
      );
    });

    testWidgets('app contains Feed and Play action buttons', (tester) async {
      await pumpApp(tester);

      expect(find.widgetWithText(FilledButton, 'Feed'), findsOneWidget);

      expect(find.widgetWithText(FilledButton, 'Play'), findsOneWidget);
    });
  });
}
