import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_roulette/models/meal_category.dart';
import 'package:food_roulette/providers/category_provider.dart';
import 'package:food_roulette/screens/home_screen.dart';
import 'package:food_roulette/services/storage_service.dart';
import 'package:food_roulette/widgets/category_card.dart';

Widget createTestWidget() {
  SharedPreferences.setMockInitialValues({});
  return ChangeNotifierProvider(
    create: (_) => CategoryProvider(storageService: StorageService()),
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('renders exactly 5 category cards', (tester) async {
      // Use a tall surface so all 5 cards in the 2-column grid are rendered
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final categoryCards = find.byType(CategoryCard);
      expect(categoryCards, findsNWidgets(5));
    });

    testWidgets('tapping a category card navigates to ShopListScreen',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the first category card (Breakfast)
      await tester.tap(find.byType(CategoryCard).first);
      await tester.pumpAndSettle();

      // Verify ShopListScreen is shown with the category's displayName in the AppBar
      expect(find.text('Breakfast'), findsOneWidget);
    });

    testWidgets('each card displays correct label and icon', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify each category's displayName and icon are present
      for (final category in MealCategory.values) {
        expect(find.text(category.displayName), findsOneWidget);
      }

      for (final category in MealCategory.values) {
        expect(find.byIcon(category.icon), findsOneWidget);
      }
    });
  });
}
