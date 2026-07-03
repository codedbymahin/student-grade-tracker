import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subject.dart';
import '../providers/subject_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/subject_card.dart';
import '../widgets/swipe_background.dart';
import 'edit_subject_dialog.dart';

/// Lists every subject with swipe-to-delete, edit and an Undo action.
///
/// The search query lives in local widget state — it only filters
/// what is displayed and never mutates [SubjectProvider].
class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_query == _searchCtrl.text) return;
    setState(() => _query = _searchCtrl.text);
  }

  /// Filters [subjects] case-insensitively by [_query]. Returns the
  /// original list reference when the query is empty so the empty-
  /// state branch is never taken accidentally.
  List<Subject> _applyFilter(List<Subject> subjects) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return subjects;
    return subjects.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _openEdit(Subject subject) async {
    final updated = await EditSubjectDialog.show(context, subject);
    if (updated != null && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Subject updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<SubjectProvider>().subjects;

    if (all.isEmpty) {
      return const EmptyState(
        icon: Icons.menu_book_rounded,
        title: 'No subjects yet',
        message:
            'Add your first subject from the Add Subject tab to see it here.',
      );
    }

    final filtered = _applyFilter(all);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search subjects...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => _searchCtrl.clear(),
                    ),
              isDense: true,
            ),
          ),
        ),
        if (filtered.isEmpty)
          const Expanded(
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No matching subjects found',
              message:
                  'Try a different keyword, or clear the search to see all '
                  'subjects.',
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final subject = filtered[index];
                // Preserve the original list index for Undo logic.
                final originalIndex = all.indexOf(subject);
                return _DismissibleRow(
                  subject: subject,
                  index: originalIndex,
                  onEdit: () => _openEdit(subject),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _DismissibleRow extends StatelessWidget {
  const _DismissibleRow({
    required this.subject,
    required this.index,
    required this.onEdit,
  });

  final Subject subject;
  final int index;
  final VoidCallback onEdit;

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
            content: const Text('Subject deleted.'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => provider.restore(subject, index: index),
            ),
          ),
        );
      },
      child: SubjectCard(subject: subject, onEdit: onEdit),
    );
  }
}
