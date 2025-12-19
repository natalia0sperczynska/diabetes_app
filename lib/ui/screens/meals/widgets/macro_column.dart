import 'package:flutter/material.dart';

class MacroColumn extends StatelessWidget {
  final String label;
  final double consumed;
  final int goal;

  const MacroColumn({
    required this.label,
    required this.consumed,
    required this.goal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (consumed / goal).clamp(0.0, 1.0);

    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        SizedBox(
          width: 60,
          child: LinearProgressIndicator(value: progress),
        ),
        const SizedBox(height: 6),
        Text('${consumed.toStringAsFixed(1)} / $goal g'),
      ],
    );
  }
}