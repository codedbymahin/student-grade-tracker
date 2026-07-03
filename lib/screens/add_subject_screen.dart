import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/grade.dart';
import '../providers/navigation_provider.dart';
import '../providers/subject_provider.dart';
import '../widgets/grade_chip.dart';

/// Form for adding a new subject. Uses local form state only — the
/// actual data lives in [SubjectProvider].
class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _markCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _markFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Re-evaluate preview grade when the user types a mark.
    _markCtrl.addListener(_onMarkChanged);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _markCtrl.dispose();
    _nameFocus.dispose();
    _markFocus.dispose();
    super.dispose();
  }

  void _onMarkChanged() {
    if (mounted) setState(() {}); // refresh the preview chip
  }

  Grade? get _previewGrade {
    final raw = _markCtrl.text.trim();
    if (raw.isEmpty) return null;
    final n = double.tryParse(raw);
    if (n == null) return null;
    return Grade.fromMark(n);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    final mark = double.parse(_markCtrl.text.trim());

    context.read<SubjectProvider>().addSubject(name: name, mark: mark);

    _nameCtrl.clear();
    _markCtrl.clear();
    _nameFocus.requestFocus();

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Subject added successfully.'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => context.read<NavigationProvider>().setIndex(1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(theme: theme),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameCtrl,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              maxLength: 40,
              decoration: const InputDecoration(
                labelText: 'Subject name',
                hintText: 'e.g. Mathematics',
                prefixIcon: Icon(Icons.menu_book_rounded),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Subject name cannot be empty';
                }
                if (value.trim().length < 2) {
                  return 'Subject name must be at least 2 characters';
                }
                return null;
              },
              onFieldSubmitted: (_) => _markFocus.requestFocus(),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _markCtrl,
              focusNode: _markFocus,
              textInputAction: TextInputAction.done,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,3}(\.\d{0,2})?')),
              ],
              decoration: const InputDecoration(
                labelText: 'Mark (0 - 100)',
                hintText: 'Enter a mark between 0 and 100',
                prefixIcon: Icon(Icons.score_rounded),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Mark cannot be empty';
                final n = double.tryParse(text);
                if (n == null) return 'Mark must be a number';
                if (n < 0 || n > 100) return 'Mark must be between 0 and 100';
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            if (_previewGrade != null) ...[
              const SizedBox(height: 20),
              _PreviewCard(grade: _previewGrade!),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Subject'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});
  final ThemeData theme;
  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.assignment_turned_in_rounded,
                size: 24, color: scheme.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Subject',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter the subject name and the mark you scored.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.grade});
  final Grade grade;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GradeChip(grade: grade, heroTag: 'grade_preview'),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preview grade', style: theme.textTheme.titleMedium),
                  Text(
                    '≥ ${grade.minMark.toStringAsFixed(0)} → ${grade.letter}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
