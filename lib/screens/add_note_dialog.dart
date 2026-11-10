import 'package:flutter/material.dart';

/// A dialog that returns (title, body), or null if the user cancels. Given.
///
///   final result = await showDialog<(String, String)>(
///       context: context, builder: (_) => const AddNoteDialog());
class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New note'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          TextField(
            controller: _body,
            decoration: const InputDecoration(labelText: 'Body'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, (_title.text, _body.text)),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
