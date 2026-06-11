import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/food_shop.dart';
import '../models/meal_category.dart';

/// Handles reading and writing shop lists to SharedPreferences.
///
/// Data is stored as a JSON string under the key [_storageKey].
/// Each meal category maps to a list of serialized [FoodShop] objects.
class StorageService {
  static const String _storageKey = 'food_roulette_data';

  /// Saves all shop lists as JSON to SharedPreferences.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> saveShopLists(Map<MealCategory, List<FoodShop>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> jsonMap = {};

      for (final category in MealCategory.values) {
        final shops = data[category] ?? [];
        jsonMap[category.name] = shops.map((shop) => shop.toJson()).toList();
      }

      final jsonString = jsonEncode(jsonMap);
      return await prefs.setString(_storageKey, jsonString);
    } catch (_) {
      return false;
    }
  }

  /// Loads shop lists from SharedPreferences.
  ///
  /// Returns the deserialized map on success, or `null` if the data is
  /// unavailable, corrupted, or unparseable.
  Future<Map<MealCategory, List<FoodShop>>?> loadShopLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null) {
        return null;
      }

      final Map<String, dynamic> jsonMap =
          jsonDecode(jsonString) as Map<String, dynamic>;

      final Map<MealCategory, List<FoodShop>> result = {};

      for (final category in MealCategory.values) {
        final List<dynamic>? shopListJson =
            jsonMap[category.name] as List<dynamic>?;

        if (shopListJson != null) {
          result[category] = shopListJson
              .map((item) => FoodShop.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          result[category] = [];
        }
      }

      return result;
    } catch (_) {
      return null;
    }
  }
}
