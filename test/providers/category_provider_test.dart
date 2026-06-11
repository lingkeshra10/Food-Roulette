import 'package:flutter_test/flutter_test.dart';

import 'package:food_roulette/models/food_shop.dart';
import 'package:food_roulette/models/meal_category.dart';
import 'package:food_roulette/models/result_types.dart';
import 'package:food_roulette/providers/category_provider.dart';
import 'package:food_roulette/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A fake StorageService that can be configured to fail on save operations.
class FakeStorageService extends StorageService {
  bool shouldFailOnSave = false;

  @override
  Future<bool> saveShopLists(Map<MealCategory, List<FoodShop>> data) async {
    if (shouldFailOnSave) {
      return false;
    }
    return super.saveShopLists(data);
  }
}

void main() {
  group('CategoryProvider Unit Tests', () {
    /// **Validates: Requirements 2.1, 2.2**
    ///
    /// Adding a shop with exactly 51 characters should return emptyName.
    test('addShop with exactly 51 characters fails with emptyName', () async {
      SharedPreferences.setMockInitialValues({});

      final storageService = StorageService();
      final provider = CategoryProvider(storageService: storageService);
      await provider.loadData();

      // Generate a 51-character name
      final name51 = 'a' * 51;
      expect(name51.length, equals(51));

      final result = await provider.addShop(MealCategory.lunch, name51);

      expect(result, equals(AddShopResult.emptyName));
      // Verify list is unchanged
      expect(provider.getShops(MealCategory.lunch), isEmpty);
    });

    /// **Validates: Requirements 2.3**
    ///
    /// Removing the only shop in a category should result in an empty list.
    test('removeShop on the only shop results in empty list', () async {
      SharedPreferences.setMockInitialValues({});

      final storageService = StorageService();
      final provider = CategoryProvider(storageService: storageService);
      await provider.loadData();

      // Add a single shop first
      final result = await provider.addShop(MealCategory.dinner, 'Only Shop');
      expect(result, equals(AddShopResult.success));
      expect(provider.getShops(MealCategory.dinner).length, equals(1));

      // Remove the only shop
      final shop = provider.getShops(MealCategory.dinner).first;
      final removeResult =
          await provider.removeShop(MealCategory.dinner, shop);

      expect(removeResult, equals(RemoveShopResult.success));
      expect(provider.getShops(MealCategory.dinner), isEmpty);
    });

    /// **Validates: Requirements 3.3, 3.4**
    ///
    /// addShop should return storageFailed when the storage service fails to
    /// persist data.
    test('addShop returns storageFailed on save error', () async {
      SharedPreferences.setMockInitialValues({});

      final fakeStorage = FakeStorageService();
      final provider = CategoryProvider(storageService: fakeStorage);
      await provider.loadData();

      // Configure the fake to fail on save
      fakeStorage.shouldFailOnSave = true;

      final result =
          await provider.addShop(MealCategory.breakfast, 'Test Shop');

      expect(result, equals(AddShopResult.storageFailed));
      // The shop is still added in memory despite storage failure
      expect(provider.getShops(MealCategory.breakfast).length, equals(1));
      expect(
          provider.getShops(MealCategory.breakfast).first.name, 'Test Shop');
    });

    /// **Validates: Requirements 3.3**
    ///
    /// loadData should initialize with empty lists for all categories when
    /// storage returns null (no saved data).
    test('loadData initializes with empty lists when storage returns null',
        () async {
      // Empty SharedPreferences — loadShopLists will return null
      SharedPreferences.setMockInitialValues({});

      final storageService = StorageService();
      final provider = CategoryProvider(storageService: storageService);
      await provider.loadData();

      // All categories should have empty lists
      for (final category in MealCategory.values) {
        expect(
          provider.getShops(category),
          isEmpty,
          reason: '${category.name} should have an empty list',
        );
      }
    });
  });
}
