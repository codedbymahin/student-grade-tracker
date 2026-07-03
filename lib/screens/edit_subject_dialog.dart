import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/subject.dart';
import '../providers/subject_provider.dart';

/// Modal dialog for editing an existing [Subject].
///
/// Validation rules mirror [AddSubjectScreen]:
///   * Name must not be empty (and at least 2 characters).
///   * Mark must be a number between 0 and 100.
///
/// On Save, the dialog calls [SubjectProvider.updateById] and then
/// pops with the updated subject so the caller can show a snackbar.
class EditSubjectDialog extends StatefulWidget {
  const EditSubjectDialog({super.key, required this.subject});

  final Subject subject;

  /// Convenience helper that shows the dialog using the navigator
  /// resolved from the given [context].
  static Future<Subject?> show(BuildContext context, Subject subject) {
    return showDialog<Subject>(
      context: context,
      builder: (_) => EditSubjectDialog(subject: subject),
    );
  }

  @override
  State<EditSubjectDialog> createState() => _EditSubjectDialogState();
}

class _EditSubjectDialogState extends State<EditSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _markCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.subject.name);
    // Show integer marks without a trailing .0.
    final mark = widget.subject.mark;
    _markCtrl = TextEditingController(
      text: mark == mark.roundToDouble()
          ? mark.toStringAsFixed(0)
          : mark.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _markCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final updated = context.read<SubjectProvider>().updateById(
          widget.subject.id,
          name: _nameCtrl.text.trim(),
          mark: double.parse(_markCtrl.text.trim()),
        );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit subject'),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              maxLength: 40,
              decoration: const InputDecoration(
                labelText: 'Subject name',
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
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _markCtrl,
              textInputAction: TextInputAction.done,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d{0,3}(\.\d{0,2})?'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Mark (0 - 100)',
                hintText: 'Enter a mark between 0 and 100',
                prefixIcon: Icon(Icons.score_rounded),
              ),
              onFieldSubmitted: (_) => _submit(),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Mark cannot be empty';
                final n = double.tryParse(text);
                if (n == null) return 'Mark must be a number';
                if (n < 0 || n > 100) return 'Mark must be between 0 and 100';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Save'),
        ),
      ],
    );
  }
}
