import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_roulette/main.dart';
import 'package:food_roulette/screens/shop_list_screen.dart';

/// Integration test for the full add/persist/reload flow.
///
/// Validates Requirements 2.1, 3.1, 3.2:
/// - Adding a shop appends it to the category's shop list
/// - Data is saved to local storage after add
/// - Data is loaded from local storage on app launch
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full flow: add shop, persist, and reload verifies data loaded',
      (WidgetTester tester) async {
    // Start with a clean SharedPreferences slate
    SharedPreferences.setMockInitialValues({});

    // Launch the app
    await tester.pumpWidget(const FoodRouletteApp());
    await tester.pumpAndSettle();

    // Verify home screen displays category cards
    expect(find.text('Food Roulette'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);

    // Tap the "Breakfast" category card to navigate to ShopListScreen
    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();

    // Verify we're on the ShopListScreen for Breakfast
    expect(find.byType(ShopListScreen), findsOneWidget);
    expect(find.text('No shops yet. Tap + to add one!'), findsOneWidget);

    // Tap the FAB to open AddShopDialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify dialog is shown
    expect(find.text('Add Shop'), findsOneWidget);

    // Enter a shop name and submit
    await tester.enterText(find.byType(TextField), 'Kedai Roti Bakar');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify the shop appears in the list
    expect(find.text('Kedai Roti Bakar'), findsOneWidget);
    expect(find.text('No shops yet. Tap + to add one!'), findsNothing);

    // Verify data was persisted to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('food_roulette_data');
    expect(savedData, isNotNull);
    expect(savedData, contains('Kedai Roti Bakar'));

    // Simulate app relaunch by rebuilding the widget tree
    // SharedPreferences persists within the process, so data should reload
    await tester.pumpWidget(const FoodRouletteApp());
    await tester.pumpAndSettle();

    // Verify home screen loads again
    expect(find.text('Food Roulette'), findsOneWidget);

    // Navigate back to Breakfast category
    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();

    // Verify the previously added shop is still there after "relaunch"
    expect(find.text('Kedai Roti Bakar'), findsOneWidget);
  });
}
