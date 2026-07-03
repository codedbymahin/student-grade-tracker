import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subject.dart';
import '../providers/subject_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/subject_card.dart';
import '../widgets/swipe_background.dart';

/// Lists every subject with swipe-to-delete and an Undo action.
class SubjectListScreen extends StatelessWidget {
  const SubjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<SubjectProvider>().subjects;

    if (subjects.isEmpty) {
      return const EmptyState(
        icon: Icons.menu_book_rounded,
        title: 'No subjects yet',
        message: 'Add one from the Add tab to get started.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _DismissibleRow(subject: subject, index: index);
      },
    );
  }
}

class _DismissibleRow extends StatelessWidget {
  const _DismissibleRow({required this.subject, required this.index});

  final Subject subject;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(subject.id),
      direction: DismissDirection.endToStart,
      background: const SwipeBackground(),
      onDismissed: (_) {
        final provider = context.read<SubjectProvider>();
        provider.deleteById(subject.id);
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('${subject.name} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => provider.restore(subject, index: index),
            ),
          ),
        );
      },
      child: SubjectCard(subject: subject),
    );
  }
}
