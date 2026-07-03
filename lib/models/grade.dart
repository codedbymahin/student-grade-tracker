import 'package:flutter/foundation.dart';

/// Letter grade produced from a numeric mark.
///
/// Boundaries: A ≥ 80, B ≥ 65, C ≥ 50, F otherwise. The boundary list is
/// the single source of truth and is mirrored by [Subject.grade].
@immutable
class Grade {
  const Grade._(this.letter, this.minMark);

  /// Letter glyph (`A`, `B`, `C`, `F`) shown in the UI.
  final String letter;

  /// Lowest mark (inclusive) that still earns this grade.
  final double minMark;

  static const a = Grade._('A', 80);
  static const b = Grade._('B', 65);
  static const c = Grade._('C', 50);
  static const f = Grade._('F', 0);

  static const values = <Grade>[a, b, c, f];

  /// Resolve [mark] (0–100) to the matching [Grade].
  ///
  /// Returns [f] for marks that are not finite or fall outside the 0–100
  /// range so the UI never crashes on bad data.
  static Grade fromMark(num mark) {
    if (mark.isNaN || mark.isInfinite) return f;
    final clamped = mark < 0
        ? 0.0
        : mark > 100
            ? 100.0
            : mark.toDouble();
    for (final g in values) {
      if (clamped >= g.minMark) return g;
    }
    return f;
  }

  @override
  String toString() => 'Grade($letter, ≥$minMark)';
}
