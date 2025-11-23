import 'package:flutter/material.dart';

// Changed ButtonStyles to functions that take BuildContext and use theme colors dynamically

ButtonStyle resetButtonStyle(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return ElevatedButton.styleFrom(
    backgroundColor: colorScheme.surface,
    foregroundColor: colorScheme.onSurface,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
      side: BorderSide(color: colorScheme.primary, width: 2),
    ),
  );
}

ButtonStyle saveButtonStyle(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return ElevatedButton.styleFrom(
    backgroundColor: colorScheme.primary,
    foregroundColor: colorScheme.onPrimary,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    ),
  );
}
