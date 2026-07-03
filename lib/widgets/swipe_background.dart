import 'package:flutter/material.dart';

/// Trailing edge background of a [Dismissible] card. Rounded so the
/// swipe hint matches the card's own corners.
class SwipeBackground extends StatelessWidget {
  const SwipeBackground({super.key, this.label = 'Delete'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(color: scheme.onErrorContainer, fontWeight: FontWeight.w600);
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: textStyle),
          const SizedBox(width: 8),
          Icon(Icons.delete_outline, color: scheme.onErrorContainer),
        ],
      ),
    );
  }
}
