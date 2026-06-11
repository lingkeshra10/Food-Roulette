import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_shop.dart';
import '../models/meal_category.dart';
import '../models/result_types.dart';
import '../providers/category_provider.dart';
import '../widgets/add_shop_dialog.dart';
import '../widgets/shop_list_item.dart';
import 'roulette_screen.dart';

/// Displays the food shops for a selected category with add/remove
/// capabilities and a spin button to navigate to the roulette.
class ShopListScreen extends StatelessWidget {
  const ShopListScreen({Key? key, required this.category}) : super(key: key);

  final MealCategory category;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final shops = provider.getShops(category);
    final canSpin = shops.length >= 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.displayName),
        backgroundColor: category.color,
      ),
      body: Column(
        children: [
          Expanded(
            child: shops.isEmpty
                ? const Center(
                    child: Text(
                      'No shops yet. Tap + to add one!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: shops.length,
                    itemBuilder: (context, index) {
                      final shop = shops[index];
                      return ShopListItem(
                        shop: shop,
                        onRemove: () => _removeShop(context, provider, shop),
                      );
                    },
                  ),
          ),
          if (!canSpin)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Add at least 2 shops to spin the roulette',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canSpin
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RouletteScreen(category: category),
                          ),
                        )
                    : null,
                icon: const Icon(Icons.casino),
                label: const Text('Spin'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AddShopDialog(category: category),
        ),
        backgroundColor: category.color,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _removeShop(
    BuildContext context,
    CategoryProvider provider,
    FoodShop shop,
  ) async {
    final result = await provider.removeShop(category, shop);
    if (result == RemoveShopResult.storageFailed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save changes. Data may not persist.'),
        ),
      );
    }
  }
}
