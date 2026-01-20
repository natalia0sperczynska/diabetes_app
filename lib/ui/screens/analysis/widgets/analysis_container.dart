import 'package:flutter/material.dart';

class AnalysisContainer extends StatelessWidget{
  final Widget child;
  final Color color;

  const AnalysisContainer({super.key,required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
    decoration: ShapeDecoration(
      color: colorScheme.surface.withOpacity(0.85),
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