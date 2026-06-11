import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/food_shop.dart';

/// An animated wheel visualization for the roulette spinner.
///
/// Uses the provided [animation] to rotate a wheel displaying shop names.
/// When [selectedShop] is not null (animation complete), the selected shop
/// is highlighted prominently.
class SpinnerWidget extends StatelessWidget {
  const SpinnerWidget({
    Key? key,
    required this.animation,
    required this.shops,
    this.selectedShop,
  }) : super(key: key);

  final Animation<double> animation;
  final List<FoodShop> shops;
  final FoodShop? selectedShop;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: animation.value * 2 * math.pi * 5,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.deepOrange,
                width: 4,
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _WheelPainter(shops: shops),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter that draws shop name segments in a wheel layout.
class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.shops});

  final List<FoodShop> shops;

  static const List<Color> _segmentColors = [
    Color(0xFFFF8A65),
    Color(0xFFFFD54F),
    Color(0xFF81C784),
    Color(0xFF64B5F6),
    Color(0xFFCE93D8),
    Color(0xFFFFAB91),
    Color(0xFFA5D6A7),
    Color(0xFF90CAF9),
    Color(0xFFE6EE9C),
    Color(0xFFF48FB1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (shops.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final sweepAngle = 2 * math.pi / shops.length;

    for (var i = 0; i < shops.length; i++) {
      final startAngle = i * sweepAngle - math.pi / 2;
      final paint = Paint()
        ..color = _segmentColors[i % _segmentColors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw separator lines between segments
      final separatorPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final endX = center.dx + radius * math.cos(startAngle);
      final endY = center.dy + radius * math.sin(startAngle);
      canvas.drawLine(center, Offset(endX, endY), separatorPaint);

      // Draw shop name text
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.6;
      final textX = center.dx + textRadius * math.cos(textAngle);
      final textY = center.dy + textRadius * math.sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: shops[i].name.length > 8
              ? '${shops[i].name.substring(0, 8)}...'
              : shops[i].name,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: radius * 0.5);

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + math.pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.shops != shops;
  }
}
