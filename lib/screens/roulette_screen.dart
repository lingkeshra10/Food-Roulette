import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_shop.dart';
import '../models/meal_category.dart';
import '../providers/category_provider.dart';
import '../widgets/spinner_widget.dart';

/// Animated spinner screen that randomly selects a food shop from the
/// category's list.
///
/// Uses [SingleTickerProviderStateMixin] for animation control with a
/// 3-second duration and deceleration curve for a natural slowdown effect.
class RouletteScreen extends StatefulWidget {
  const RouletteScreen({Key? key, required this.category}) : super(key: key);

  final MealCategory category;

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  FoodShop? _selectedShop;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final shop = _pickRandomShop();
        setState(() {
          _selectedShop = shop;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Initiates the spin animation and picks a random shop on completion.
  void _startSpin() {
    setState(() {
      _selectedShop = null;
    });
    _controller.reset();
    _controller.forward();
  }

  /// Selects a random shop using the CategoryProvider.
  FoodShop? _pickRandomShop() {
    return context.read<CategoryProvider>().pickRandom(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    final shops =
        context.watch<CategoryProvider>().getShops(widget.category);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.displayName} Roulette'),
        backgroundColor: widget.category.color,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spinner widget
              SpinnerWidget(
                animation: _animation,
                shops: shops,
                selectedShop: _selectedShop,
              ),
              const SizedBox(height: 32),

              // Selected shop result display
              if (_selectedShop != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: widget.category.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.category.color,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'You should eat at:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedShop!.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Spin / Spin Again button
              if (_selectedShop != null)
                ElevatedButton.icon(
                  onPressed: _startSpin,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Spin Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.category.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                )
              else
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return ElevatedButton.icon(
                      onPressed:
                          _controller.isAnimating ? null : _startSpin,
                      icon: const Icon(Icons.casino),
                      label: Text(
                        _controller.isAnimating ? 'Spinning...' : 'Spin!',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.category.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
