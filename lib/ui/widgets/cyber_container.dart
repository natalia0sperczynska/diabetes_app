import 'package:flutter/material.dart';

class CyberContainer extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double opacity;

  const CyberContainer({
    super.key,
    required this.child,
    this.borderColor,
    this.padding = const EdgeInsets.all(16),
    this.opacity = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = borderColor ?? colorScheme.primary;

    return Container(
      padding: padding,
      decoration: ShapeDecoration(
        color: colorScheme.surface.withOpacity(opacity),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 2),
        ),
        shadows: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}