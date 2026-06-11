import 'package:flutter/material.dart';

import '../models/food_shop.dart';

/// A dismissible list tile displaying a food shop name with delete action.
///
/// Supports both swipe-to-dismiss and a trailing delete icon button
/// for removing a shop from the list.
class ShopListItem extends StatelessWidget {
  const ShopListItem({
    Key? key,
    required this.shop,
    required this.onRemove,
  }) : super(key: key);

  final FoodShop shop;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: ValueKey(shop.name.toLowerCase()),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onRemove(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              shop.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onRemove,
              tooltip: 'Remove shop',
            ),
          ),
        ),
      ),
    );
  }
}
