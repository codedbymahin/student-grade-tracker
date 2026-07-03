import 'package:flutter/material.dart';

import '../models/grade.dart';

/// Circular badge that shows a letter grade in a colour derived from the
/// Material 3 colour scheme.
///
/// The choice of container colours follows the same convention used by
/// the rest of the UI:
/// A → tertiary container, B → primary container, C → secondary
/// container, F → error container.
class GradeChip extends StatelessWidget {
  const GradeChip({
    super.key,
    required this.grade,
    this.size = 44,
    this.heroTag,
  });

  final Grade grade;
  final double size;

  /// Optional [Hero] tag shared with another widget (e.g. an entry on the
  /// Add screen) to animate grade changes.
  final Object? heroTag;

  ({Color background, Color foreground}) _colors(ColorScheme scheme) {
    final (background, foreground) = switch (grade) {
      Grade.a => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      Grade.b => (scheme.primaryContainer, scheme.onPrimaryContainer),
      Grade.c => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      Grade.f => (scheme.errorContainer, scheme.onErrorContainer),
      Grade() => (scheme.surfaceContainerHighest, scheme.onSurface),
    };
    return (background: background, foreground: foreground);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = _colors(scheme);
    final content = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.background, shape: BoxShape.circle),
      child: Text(
        grade.letter,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: c.foreground,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
    if (heroTag == null) return content;
    return Hero(
        tag: heroTag!,
        child: Material(type: MaterialType.transparency, child: content));
  }
}
