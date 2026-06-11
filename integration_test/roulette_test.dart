import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_roulette/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add multiple shops, spin roulette, verify result is from list',
      (WidgetTester tester) async {
    // Clean state
    SharedPreferences.setMockInitialValues({});

    // Launch the app
    app.main();
    await tester.pumpAndSettle();

    // Tap the "Lunch" category card
    final lunchCard = find.text('Lunch');
    expect(lunchCard, findsOneWidget);
    await tester.tap(lunchCard);
    await tester.pumpAndSettle();

    // Add 3 shops via the add dialog
    const shopNames = ['KFC', 'MCD', 'Pizza Hut'];

    for (final name in shopNames) {
      // Tap the FAB to open the add dialog
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Enter shop name
      final textField = find.byType(TextField);
      await tester.enterText(textField, name);
      await tester.pumpAndSettle();

      // Tap "Add" button
      final addButton = find.text('Add');
      await tester.tap(addButton);
      await tester.pumpAndSettle();
    }

    // Verify all shops are displayed
    for (final name in shopNames) {
      expect(find.text(name), findsOneWidget);
    }

    // Tap the "Spin" button to navigate to RouletteScreen
    final spinButton = find.text('Spin');
    expect(spinButton, findsOneWidget);
    await tester.tap(spinButton);
    await tester.pumpAndSettle();

    // Verify we're on the roulette screen
    expect(find.text('Lunch Roulette'), findsOneWidget);

    // Tap the "Spin!" button to start the roulette
    final spinActionButton = find.text('Spin!');
    expect(spinActionButton, findsOneWidget);
    await tester.tap(spinActionButton);

    // Wait for the 3-second animation to complete
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify the result text "You should eat at:" is displayed
    expect(find.text('You should eat at:'), findsOneWidget);

    // Verify: the displayed result matches one of the added shops
    final resultFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.style?.fontSize == 28 &&
          widget.style?.fontWeight == FontWeight.bold,
    );
    expect(resultFinder, findsOneWidget);

    final resultWidget = tester.widget<Text>(resultFinder);
    final resultText = resultWidget.data!;
    expect(
      shopNames.contains(resultText),
      isTrue,
      reason:
          'Result "$resultText" should be one of $shopNames',
    );

    // Verify: "Spin Again" button is visible
    expect(find.text('Spin Again'), findsOneWidget);
  });
}
