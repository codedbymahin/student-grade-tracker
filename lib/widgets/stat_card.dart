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
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: fg),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: theme.textTheme.titleMedium),
            ),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
