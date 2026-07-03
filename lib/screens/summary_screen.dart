import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/grade.dart';
import '../providers/subject_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/stat_card.dart';

/// Live summary of the subjects in [SubjectProvider].
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubjectProvider>();
    final theme = Theme.of(context);

    if (provider.totalSubjects == 0) {
      return const EmptyState(
        icon: Icons.insights_rounded,
        title: 'Nothing to summarise',
        message:
            'Add your first subject from the Add Subject tab and your '
            'summary will appear here.',
      );
    }

    final average = provider.averageMark;
    final overall = provider.overallGrade ?? Grade.f;
    final passing = provider.passingCount;
    final failing = provider.totalSubjects - passing;
    final passingRatio = passing / provider.totalSubjects;
    final highest = provider.highestMark ?? 0;
    final lowest = provider.lowestMark ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          'Live Summary',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Auto-updates as you add or remove subjects.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _HeroCard(overall: overall, average: average),
        const SizedBox(height: 20),
        _StatGroup(
          children: [
            StatCard(
              icon: Icons.school_rounded,
              label: 'Total subjects',
              value: provider.totalSubjects.toString(),
            ),
            StatCard(
              icon: Icons.trending_up_rounded,
              label: 'Highest mark',
              value: _formatMark(highest),
            ),
            StatCard(
              icon: Icons.trending_down_rounded,
              label: 'Lowest mark',
              value: _formatMark(lowest),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionHeader(label: 'Pass / Fail breakdown'),
        const SizedBox(height: 8),
        _StatGroup(
          children: [
            StatCard(
              icon: Icons.check_circle_rounded,
              label: 'Passing subjects',
              value: passing.toString(),
              accent: theme.colorScheme.primaryContainer,
            ),
            StatCard(
              icon: Icons.cancel_rounded,
              label: 'Failing subjects',
              value: failing.toString(),
              accent: theme.colorScheme.errorContainer,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _PassingCard(
          passingCount: passing,
          totalCount: provider.totalSubjects,
          ratio: passingRatio,
        ),
      ],
    );
  }

  /// Formats a mark as an integer when whole, otherwise with one decimal.
  String _formatMark(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Vertical stack of [StatCard]s with consistent gaps between them.
class _StatGroup extends StatelessWidget {
  const _StatGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i != children.length - 1) spaced.add(const SizedBox(height: 10));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: spaced);
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.overall, required this.average});

  final Grade overall;
  final double average;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'OVERALL PERFORMANCE',
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.85),
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HeroStat(
                label: 'Grade',
                value: overall.letter,
                emphasize: true,
              ),
              Container(
                height: 56,
                width: 1,
                color: scheme.onPrimary.withValues(alpha: 0.3),
              ),
              _HeroStat(
                label: 'Average mark',
                value: _formatAverage(average),
                emphasize: false,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(_iconFor(overall),
                    color: scheme.onPrimary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _messageFor(overall),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAverage(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  IconData _iconFor(Grade g) {
    switch (g) {
      case Grade.a:
        return Icons.emoji_events_rounded;
      case Grade.b:
        return Icons.thumb_up_rounded;
      case Grade.c:
        return Icons.trending_up_rounded;
      case Grade.f:
        return Icons.refresh_rounded;
      case Grade():
        return Icons.info_outline_rounded;
    }
  }

  String _messageFor(Grade g) {
    switch (g) {
      case Grade.a:
        return 'Excellent performance!';
      case Grade.b:
        return 'Great work!';
      case Grade.c:
        return 'Keep improving!';
      case Grade.f:
        return 'Needs more practice.';
      case Grade():
        return '';
    }
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.emphasize,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onPrimary.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.displaySmall?.copyWith(
            color: scheme.onPrimary,
            fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PassingCard extends StatelessWidget {
  const _PassingCard({
    required this.passingCount,
    required this.totalCount,
    required this.ratio,
  });

  final int passingCount;
  final int totalCount;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isHealthy = ratio >= 0.5;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  isHealthy
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  color: isHealthy ? scheme.primary : scheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Passing subjects (≥ 50)',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  '$passingCount / $totalCount',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isHealthy ? scheme.primary : scheme.error,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(ratio * 100).toStringAsFixed(0)}% of subjects passing',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
