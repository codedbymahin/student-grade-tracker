import 'package:flutter/material.dart';

import '../models/subject.dart';
import 'grade_chip.dart';

/// Tile-style card showing one [Subject]. Used inside a [Dismissible] so
/// it stays purely presentational.
class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key, required this.subject});

  final Subject subject;

  String get _initials {
    final parts =
        subject.name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final list = parts.toList(growable: false);
    if (list.isEmpty) return '?';
    if (list.length == 1) return list.first[0].toUpperCase();
    return (list.first[0] + list.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Text(
            _initials,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(subject.name, style: theme.textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.score_rounded,
                  size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                'Mark ${subject.mark.toStringAsFixed(1)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        trailing: GradeChip(
          grade: subject.grade,
          heroTag: 'grade_${subject.id}',
        ),
      ),
    );
  }
}
