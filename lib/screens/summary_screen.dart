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
        message: 'Add at least one subject to see your progress here.',
      );
    }

    final average = provider.averageMark;
    final overall = provider.overallGrade ?? Grade.f;
    final passingRatio = provider.passingCount / provider.totalSubjects;
    final highest = provider.highestMark ?? 0;
    final lowest = provider.lowestMark ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          'Live Summary',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _HeroCard(overall: overall, average: average),
        const SizedBox(height: 12),
        StatCard(
          icon: Icons.school_rounded,
          label: 'Total subjects',
          value: provider.totalSubjects.toString(),
        ),
        StatCard(
          icon: Icons.trending_up_rounded,
          label: 'Highest mark',
          value: highest.toStringAsFixed(1),
        ),
        StatCard(
          icon: Icons.trending_down_rounded,
          label: 'Lowest mark',
          value: lowest.toStringAsFixed(1),
        ),
        _PassingCard(
          passingCount: provider.passingCount,
          totalCount: provider.totalSubjects,
          ratio: passingRatio,
        ),
      ],
    );
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
          colors: [scheme.primary, scheme.primaryContainer],
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
                value: average.toStringAsFixed(1),
                emphasize: false,
              ),
            ],
          ),
        ],
      ),
    );
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
