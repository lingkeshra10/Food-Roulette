import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_roulette/models/meal_category.dart';
import 'package:food_roulette/providers/category_provider.dart';
import 'package:food_roulette/screens/shop_list_screen.dart';
import 'package:food_roulette/services/storage_service.dart';

Widget createTestWidget(MealCategory category) {
  SharedPreferences.setMockInitialValues({});
  return ChangeNotifierProvider(
    create: (_) => CategoryProvider(storageService: StorageService()),
    child: MaterialApp(home: ShopListScreen(category: category)),
  );
}

void main() {
  group('ShopListScreen', () {
    testWidgets('displays shops in insertion order', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final provider = CategoryProvider(storageService: StorageService());
      await provider.loadData();

      // Add shops in a specific order
      await provider.addShop(MealCategory.lunch, 'Shop A');
      await provider.addShop(MealCategory.lunch, 'Shop B');
      await provider.addShop(MealCategory.lunch, 'Shop C');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: ShopListScreen(category: MealCategory.lunch),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all shops are displayed
      expect(find.text('Shop A'), findsOneWidget);
      expect(find.text('Shop B'), findsOneWidget);
      expect(find.text('Shop C'), findsOneWidget);

      // Verify order by checking widget positions
      final shopAOffset = tester.getTopLeft(find.text('Shop A'));
      final shopBOffset = tester.getTopLeft(find.text('Shop B'));
      final shopCOffset = tester.getTopLeft(find.text('Shop C'));

      expect(shopAOffset.dy, lessThan(shopBOffset.dy));
      expect(shopBOffset.dy, lessThan(shopCOffset.dy));
    });

    testWidgets('shows minimum-shops message when category has 0 shops',
        (tester) async {
      await tester.pumpWidget(createTestWidget(MealCategory.breakfast));
      await tester.pumpAndSettle();

      expect(
        find.text('Add at least 2 shops to spin the roulette'),
        findsOneWidget,
      );
    });

    testWidgets('shows minimum-shops message when category has 1 shop',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final provider = CategoryProvider(storageService: StorageService());
      await provider.loadData();
      await provider.addShop(MealCategory.dinner, 'Single Shop');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: ShopListScreen(category: MealCategory.dinner),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Add at least 2 shops to spin the roulette'),
        findsOneWidget,
      );
    });
  });

  group('AddShopDialog', () {
    testWidgets('shows validation error for empty input', (tester) async {
      await tester.pumpWidget(createTestWidget(MealCategory.lunch));
      await tester.pumpAndSettle();

      // Tap the FAB to open AddShopDialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text('Add Shop'), findsOneWidget);

      // Submit with empty text by tapping the Add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify validation error appears
      expect(find.text('Shop name is required'), findsOneWidget);
    });

    testWidgets('shows duplicate error for existing shop names',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final provider = CategoryProvider(storageService: StorageService());
      await provider.loadData();
      await provider.addShop(MealCategory.lunch, 'Pizza Place');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: ShopListScreen(category: MealCategory.lunch),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open the AddShopDialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter a duplicate name (same case)
      await tester.enterText(find.byType(TextField), 'Pizza Place');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify duplicate error appears
      expect(find.text('This shop already exists'), findsOneWidget);
    });
  });
}
