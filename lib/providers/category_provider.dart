import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/food_shop.dart';
import '../models/meal_category.dart';
import '../models/result_types.dart';
import '../services/storage_service.dart';

/// Manages all category and shop state, coordinates with storage.
///
/// Provides methods to load persisted data, add/remove shops with validation,
/// and pick a random shop for the roulette feature.
class CategoryProvider extends ChangeNotifier {
  CategoryProvider({required StorageService storageService})
      : _storageService = storageService,
        _shopLists = {
          for (final category in MealCategory.values) category: <FoodShop>[],
        };

  final StorageService _storageService;
  Map<MealCategory, List<FoodShop>> _shopLists;

  /// Loads saved data from storage on initialization.
  ///
  /// If storage returns null (unavailable or corrupted), keeps empty lists.
  Future<void> loadData() async {
    final loaded = await _storageService.loadShopLists();
    if (loaded != null) {
      _shopLists = loaded;
    }
    notifyListeners();
  }

  /// Returns the shop list for a given category.
  List<FoodShop> getShops(MealCategory category) {
    return List.unmodifiable(_shopLists[category] ?? <FoodShop>[]);
  }

  /// Adds a shop to a category with validation, persistence, and notification.
  ///
  /// Validation rules:
  /// - Empty or whitespace-only name → [AddShopResult.emptyName]
  /// - Name longer than 50 characters → [AddShopResult.emptyName]
  /// - Case-insensitive duplicate → [AddShopResult.duplicateName]
  ///
  /// On success, appends a new [FoodShop] with trimmed name and current
  /// timestamp, saves to storage, and notifies listeners.
  Future<AddShopResult> addShop(MealCategory category, String name) async {
    final trimmed = name.trim();

    // Validate: empty or whitespace-only
    if (trimmed.isEmpty) {
      return AddShopResult.emptyName;
    }

    // Validate: length exceeds 50 characters
    if (trimmed.length > 50) {
      return AddShopResult.emptyName;
    }

    // Validate: case-insensitive duplicate check
    final shops = _shopLists[category]!;
    final lowerName = trimmed.toLowerCase();
    final isDuplicate = shops.any(
      (shop) => shop.name.toLowerCase() == lowerName,
    );
    if (isDuplicate) {
      return AddShopResult.duplicateName;
    }

    // Create and append the new shop
    final newShop = FoodShop(name: trimmed, createdAt: DateTime.now());
    shops.add(newShop);

    // Persist to storage
    final saved = await _storageService.saveShopLists(_shopLists);
    notifyListeners();

    if (!saved) {
      return AddShopResult.storageFailed;
    }

    return AddShopResult.success;
  }

  /// Removes a shop from a category, persists, and notifies listeners.
  Future<RemoveShopResult> removeShop(
    MealCategory category,
    FoodShop shop,
  ) async {
    final shops = _shopLists[category]!;
    shops.remove(shop);

    // Persist to storage
    final saved = await _storageService.saveShopLists(_shopLists);
    notifyListeners();

    if (!saved) {
      return RemoveShopResult.storageFailed;
    }

    return RemoveShopResult.success;
  }

  /// Picks a random shop from the category with uniform distribution.
  ///
  /// Returns `null` if the category has fewer than 2 shops.
  FoodShop? pickRandom(MealCategory category) {
    final shops = _shopLists[category]!;
    if (shops.length < 2) {
      return null;
    }
    final index = Random().nextInt(shops.length);
    return shops[index];
  }
}
