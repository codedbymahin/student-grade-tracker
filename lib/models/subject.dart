import 'package:flutter/foundation.dart';

import 'grade.dart';

/// Immutable subject entry.
///
/// The mark is stored privately so callers can read it through [mark]
/// but cannot mutate it after construction. Letter grade computation
/// lives here and in [Grade] — nowhere else.
@immutable
class Subject {
  /// Stable per-instance id used by `Dismissible` keys and Undo logic.
  final String id;
  final String name;
  final double _mark;

  const Subject({
    required this.id,
    required this.name,
    required double mark,
  })  : _mark = mark,
        assert(mark >= 0 && mark <= 100, 'Mark must be within 0–100');

  /// Convenience constructor used by UI code that doesn't care about ids.
  /// A monotonic microsecond id is good enough for an in-memory list.
  factory Subject.create({required String name, required double mark}) {
    return Subject(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      mark: mark,
    );
  }

  /// Numeric mark in the 0–100 range.
  double get mark => _mark;

  /// Letter grade derived from the private mark.
  Grade get grade => Grade.fromMark(_mark);

  /// Returns a copy of this subject with the provided fields replaced.
  Subject copyWith({String? name, double? mark}) {
    return Subject(id: id, name: name ?? this.name, mark: mark ?? _mark);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          _mark == other._mark;

  @override
  int get hashCode => Object.hash(id, name, _mark);

  @override
  String toString() => 'Subject($name, $_mark, ${grade.letter})';
}
