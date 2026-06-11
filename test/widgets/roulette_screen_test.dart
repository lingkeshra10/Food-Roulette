import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_roulette/models/meal_category.dart';
import 'package:food_roulette/providers/category_provider.dart';
import 'package:food_roulette/screens/roulette_screen.dart';
import 'package:food_roulette/services/storage_service.dart';

/// Creates a test widget wrapping RouletteScreen with a pre-populated provider.
Widget createTestWidget(CategoryProvider provider) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: const MaterialApp(
      home: RouletteScreen(category: MealCategory.lunch),
    ),
  );
}

/// Creates a CategoryProvider pre-populated with test shops for the lunch category.
Future<CategoryProvider> createProviderWithShops() async {
  SharedPreferences.setMockInitialValues({});
  final provider = CategoryProvider(storageService: StorageService());
  await provider.loadData();
  await provider.addShop(MealCategory.lunch, 'Pizza Palace');
  await provider.addShop(MealCategory.lunch, 'Burger Barn');
  await provider.addShop(MealCategory.lunch, 'Sushi House');
  return provider;
}

void main() {
  group('RouletteScreen', () {
    testWidgets('shows result after animation completes', (tester) async {
      final provider = await createProviderWithShops();
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Tap the Spin button
      await tester.tap(find.text('Spin!'));
      await tester.pump();

      // Advance time past the 3-second animation duration
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Verify a result is displayed - one of the shop names should appear
      // in the result area along with the prompt text
      expect(find.text('You should eat at:'), findsOneWidget);

      // One of the shop names should be displayed as the result
      final shopNames = ['Pizza Palace', 'Burger Barn', 'Sushi House'];
      final resultFound = shopNames.any(
        (name) => find.text(name).evaluate().isNotEmpty,
      );
      expect(resultFound, isTrue,
          reason: 'Expected one of the shop names to appear as the result');
    });

    testWidgets('spin-again button is available after result display',
        (tester) async {
      final provider = await createProviderWithShops();
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Tap the Spin button
      await tester.tap(find.text('Spin!'));
      await tester.pump();

      // Advance past animation
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Verify "Spin Again" button is visible and enabled
      final spinAgainButton = find.text('Spin Again');
      expect(spinAgainButton, findsOneWidget);

      // Verify the button is tappable (enabled)
      final elevatedButton = find.widgetWithText(ElevatedButton, 'Spin Again');
      expect(elevatedButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(elevatedButton);
      expect(button.onPressed, isNotNull,
          reason: 'Spin Again button should be enabled');
    });

    testWidgets('spin button is disabled during animation', (tester) async {
      final provider = await createProviderWithShops();
      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Tap the Spin button to start animation
      await tester.tap(find.text('Spin!'));

      // Pump a small amount of time so animation is in progress
      await tester.pump(const Duration(milliseconds: 500));

      // Verify the button text changes to "Spinning..."
      expect(find.text('Spinning...'), findsOneWidget);
      expect(find.text('Spin!'), findsNothing);

      // Verify the button is disabled (onPressed is null)
      final elevatedButton =
          find.widgetWithText(ElevatedButton, 'Spinning...');
      expect(elevatedButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(elevatedButton);
      expect(button.onPressed, isNull,
          reason: 'Spin button should be disabled during animation');
    });
  });
}
