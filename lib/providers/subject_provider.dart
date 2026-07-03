import 'package:flutter/foundation.dart';

import '../models/grade.dart';
import '../models/subject.dart';

/// Holds the in-memory list of subjects and exposes computed values.
///
/// All UI state for the subject list flows from `notifyListeners()`.
class SubjectProvider extends ChangeNotifier {
  final List<Subject> _subjects = [];
  int _idSeed = 0;

  /// Read-only view of the current subject list. Order matters: callers
  /// (Undo, animations) rely on stable indices.
  List<Subject> get subjects => List.unmodifiable(_subjects);

  /// Number of subjects.
  int get totalSubjects => _subjects.length;

  /// Arithmetic mean of every stored mark. Returns `0.0` for an empty
  /// list so callers don't have to special-case it.
  double get averageMark {
    if (_subjects.isEmpty) return 0.0;
    final total = _subjects.map((s) => s.mark).fold<double>(0, (a, b) => a + b);
    return total / _subjects.length;
  }

  /// Letter grade that corresponds to [averageMark]. Returns `null` when
  /// the list is empty so the summary screen can render its own
  /// placeholder.
  Grade? get overallGrade {
    if (_subjects.isEmpty) return null;
    return Grade.fromMark(averageMark);
  }

  /// Number of subjects with a mark of 50 or above.
  int get passingCount => _subjects.where((s) => s.mark >= 50).length;

  /// Highest mark in the list, or `null` when empty.
  double? get highestMark {
    if (_subjects.isEmpty) return null;
    return _subjects.map((s) => s.mark).reduce((a, b) => a >= b ? a : b);
  }

  /// Lowest mark in the list, or `null` when empty.
  double? get lowestMark {
    if (_subjects.isEmpty) return null;
    return _subjects.map((s) => s.mark).reduce((a, b) => a <= b ? a : b);
  }

  /// Adds a subject to the end of the list. [name] is trimmed.
  void addSubject({required String name, required double mark}) {
    final cleaned = name.trim();
    if (cleaned.isEmpty) return;
    final clamped = mark.clamp(0.0, 100.0);
    _idSeed += 1;
    _subjects.add(Subject(
      id: 's_${DateTime.now().microsecondsSinceEpoch}_$_idSeed',
      name: cleaned,
      mark: clamped.toDouble(),
    ));
    notifyListeners();
  }

  /// Removes the subject with [id]. Returns the removed subject or `null`
  /// if no subject matched — useful for Undo.
  Subject? deleteById(String id) {
    final index = _indexOf(id);
    if (index == null) return null;
    final removed = _subjects.removeAt(index);
    notifyListeners();
    return removed;
  }

  /// Re-inserts [subject] at [index]. Bounds are clamped so a stale
  /// Undo after several other deletions can never throw.
  void restore(Subject subject, {required int index}) {
    if (_subjects.any((s) => s.id == subject.id)) return;
    final clampedIndex = index.clamp(0, _subjects.length);
    _subjects.insert(clampedIndex, subject);
    notifyListeners();
  }

  /// Clears every subject. Provided for completeness even though the UI
  /// does not expose it yet.
  void clear() {
    if (_subjects.isEmpty) return;
    _subjects.clear();
    notifyListeners();
  }

  int? _indexOf(String id) {
    for (var i = 0; i < _subjects.length; i++) {
      if (_subjects[i].id == id) return i;
    }
    return null;
  }
}
