import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_shop.dart';
import '../models/meal_category.dart';
import '../providers/category_provider.dart';

/// A dialog for adding a new food shop to a meal category.
///
/// Includes inline validation for empty/whitespace names, length limits,
/// and case-insensitive duplicate detection.
class AddShopDialog extends StatefulWidget {
  const AddShopDialog({Key? key, required this.category}) : super(key: key);

  final MealCategory category;

  @override
  State<AddShopDialog> createState() => _AddShopDialogState();
}

class _AddShopDialogState extends State<AddShopDialog> {
  final TextEditingController _nameController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Validates input against rules:
  /// - Non-empty and non-whitespace-only
  /// - 1-50 characters
  /// - No case-insensitive duplicates in existing shops
  String? _validate(String value, List<FoodShop> existingShops) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return 'Shop name is required';
    }

    if (trimmed.length > 50) {
      return 'Name must be 50 characters or less';
    }

    final lowerName = trimmed.toLowerCase();
    final isDuplicate = existingShops.any(
      (shop) => shop.name.toLowerCase() == lowerName,
    );
    if (isDuplicate) {
      return 'This shop already exists';
    }

    return null;
  }

  /// Submits the validated shop name to the provider and closes the dialog.
  Future<void> _submit() async {
    final provider = context.read<CategoryProvider>();
    final existingShops = provider.getShops(widget.category);
    final error = _validate(_nameController.text, existingShops);

    if (error != null) {
      setState(() {
        _errorText = error;
      });
      return;
    }

    final trimmedName = _nameController.text.trim();
    await provider.addShop(widget.category, trimmedName);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Shop'),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Shop name',
          errorText: _errorText,
        ),
        onChanged: (_) {
          // Clear error when user types
          if (_errorText != null) {
            setState(() {
              _errorText = null;
            });
          }
        },
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
