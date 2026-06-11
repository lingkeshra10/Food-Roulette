import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_roulette/models/food_shop.dart';
import 'package:food_roulette/models/meal_category.dart';
import 'package:food_roulette/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;

  setUp(() {
    storageService = StorageService();
  });

  group('StorageService', () {
    group('save and load empty lists', () {
      test('saving empty lists for all categories and loading returns empty lists', () async {
        SharedPreferences.setMockInitialValues({});

        final Map<MealCategory, List<FoodShop>> emptyData = {
          for (final category in MealCategory.values) category: <FoodShop>[],
        };

        final saveResult = await storageService.saveShopLists(emptyData);
        expect(saveResult, isTrue);

        final loaded = await storageService.loadShopLists();
        expect(loaded, isNotNull);

        for (final category in MealCategory.values) {
          expect(loaded![category], isEmpty);
        }
      });
    });

    group('load from empty SharedPreferences', () {
      test('loading when no stored value exists returns null', () async {
        SharedPreferences.setMockInitialValues({});

        final result = await storageService.loadShopLists();
        expect(result, isNull);
      });
    });

    group('load corrupted JSON', () {
      test('loading invalid JSON string returns null', () async {
        SharedPreferences.setMockInitialValues({
          'food_roulette_data': 'not valid json {{{',
        });

        final result = await storageService.loadShopLists();
        expect(result, isNull);
      });
    });

    group('save and load with data', () {
      test('saving shops in various categories and loading preserves data and order', () async {
        SharedPreferences.setMockInitialValues({});

        final now = DateTime.utc(2024, 3, 15, 10, 30);
        final Map<MealCategory, List<FoodShop>> data = {
          MealCategory.breakfast: [
            FoodShop(name: 'Kedai Roti', createdAt: now),
            FoodShop(name: 'Toast Box', createdAt: now.add(const Duration(hours: 1))),
          ],
          MealCategory.lunch: [
            FoodShop(name: 'Nasi Kandar', createdAt: now),
          ],
          MealCategory.teaTime: [],
          MealCategory.dinner: [
            FoodShop(name: 'Sushi King', createdAt: now),
            FoodShop(name: 'Pizza Hut', createdAt: now.add(const Duration(hours: 2))),
            FoodShop(name: 'KFC', createdAt: now.add(const Duration(hours: 3))),
          ],
          MealCategory.supper: [],
        };

        final saveResult = await storageService.saveShopLists(data);
        expect(saveResult, isTrue);

        final loaded = await storageService.loadShopLists();
        expect(loaded, isNotNull);

        // Verify breakfast
        expect(loaded![MealCategory.breakfast]!.length, equals(2));
        expect(loaded[MealCategory.breakfast]![0].name, equals('Kedai Roti'));
        expect(loaded[MealCategory.breakfast]![1].name, equals('Toast Box'));

        // Verify lunch
        expect(loaded[MealCategory.lunch]!.length, equals(1));
        expect(loaded[MealCategory.lunch]![0].name, equals('Nasi Kandar'));

        // Verify teaTime is empty
        expect(loaded[MealCategory.teaTime], isEmpty);

        // Verify dinner order is preserved
        expect(loaded[MealCategory.dinner]!.length, equals(3));
        expect(loaded[MealCategory.dinner]![0].name, equals('Sushi King'));
        expect(loaded[MealCategory.dinner]![1].name, equals('Pizza Hut'));
        expect(loaded[MealCategory.dinner]![2].name, equals('KFC'));

        // Verify supper is empty
        expect(loaded[MealCategory.supper], isEmpty);
      });
    });
  });
}
