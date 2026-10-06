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

  Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text);

    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();

    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('Digital Pet - Core State Tests', () {
    testWidgets('Pet starts with correct default values', (tester) async {
      await pumpApp(tester);

      expect(find.text('My Pet'), findsOneWidget);
      expect(find.text('Happiness: 50'), findsOneWidget);
      expect(find.text('Hunger: 50'), findsOneWidget);
      expect(find.text('Energy: 100'), findsOneWidget);
      expect(find.text('Neutral'), findsOneWidget);
    });

    testWidgets('Feed changes hunger and happiness', (tester) async {
      await pumpApp(tester);

      await tapText(tester, 'Feed');

      expect(find.text('Happiness: 60'), findsOneWidget);
      expect(find.text('Hunger: 40'), findsOneWidget);
    });

    testWidgets('Play changes happiness and hunger', (tester) async {
      await pumpApp(tester);

      await tapText(tester, 'Play');

      expect(find.text('Happiness: 65'), findsOneWidget);
      expect(find.text('Hunger: 55'), findsOneWidget);
    });

    testWidgets('Feed keeps hunger within lower bound', (tester) async {
      await pumpApp(tester);

      for (int i = 0; i < 6; i++) {
        await tapText(tester, 'Feed');
      }

      expect(find.text('Hunger: 0'), findsOneWidget);
    });

    testWidgets('Play keeps happiness within upper bound', (tester) async {
      await pumpApp(tester);

      // 50 -> 65 -> 80 -> 95 -> 100
      for (int i = 0; i < 4; i++) {
        await tapText(tester, 'Play');
      }

      expect(find.text('Happiness: 100'), findsOneWidget);

      // One more Play must remain at 100.
      await tapText(tester, 'Play');

      expect(find.text('Happiness: 100'), findsOneWidget);
    });

    testWidgets('Reset restores the initial state', (tester) async {
      await pumpApp(tester);

      await tapText(tester, 'Play');

      expect(find.text('Happiness: 65'), findsOneWidget);

      await tapText(tester, 'Reset');

      expect(find.text('My Pet'), findsOneWidget);
      expect(find.text('Happiness: 50'), findsOneWidget);
      expect(find.text('Hunger: 50'), findsOneWidget);
      expect(find.text('Energy: 100'), findsOneWidget);
      expect(find.text('Neutral'), findsOneWidget);
    });

    testWidgets('Pet name can be confirmed', (tester) async {
      await pumpApp(tester);

      final textField = find.byType(TextField);

      await tester.ensureVisible(textField);
      await tester.pumpAndSettle();

      await tester.enterText(textField, 'Buddy');

      await tapText(tester, 'Confirm Name');

      expect(find.text('Buddy'), findsOneWidget);
    });

    testWidgets('Pet name rejects empty input', (tester) async {
      await pumpApp(tester);

      await tapText(tester, 'Confirm Name');

      expect(find.text('Please enter a pet name.'), findsOneWidget);
    });

    testWidgets('Mood changes when happiness increases', (tester) async {
      await pumpApp(tester);

      // 50 -> 65 -> 80 -> 95
      for (int i = 0; i < 3; i++) {
        await tapText(tester, 'Play');
      }

      expect(find.text('Happy'), findsOneWidget);
    });

    testWidgets('Feed at low hunger applies the low-hunger rule', (
      tester,
    ) async {
      await pumpApp(tester);

      // Hunger: 50 -> 40 -> 30 -> 20
      await tapText(tester, 'Feed');
      await tapText(tester, 'Feed');
      await tapText(tester, 'Feed');

      expect(find.text('Hunger: 20'), findsOneWidget);

      // At low hunger, another Feed applies the happiness penalty.
      await tapText(tester, 'Feed');

      expect(find.text('Hunger: 10'), findsOneWidget);
      expect(find.text('Happiness: 30'), findsOneWidget);
    });
  });
}
