import 'package:flutter/material.dart';

/// Compact statistic card used by the Summary screen.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accent,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Container colour for the leading circle. Defaults to the secondary
  /// container so the card blends with the surface.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = accent ?? scheme.secondaryContainer;
    final fg = accent == null
        ? scheme.onSecondaryContainer
        : scheme.onPrimaryContainer;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: bg, foregroundColor: fg, child: Icon(icon)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: theme.textTheme.titleMedium),
            ),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
