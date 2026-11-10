import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/auth_repository.dart';
import '../data/notes_repository.dart';
import '../models/note.dart';
import 'add_note_dialog.dart';

/// Part 4: the signed-in user's notes, live from Firestore.
///
/// - AppBar title 'My Notes'; an IconButton (tooltip 'Sign out', Icons.logout)
///   that calls AuthRepository.signOut().
/// - A FloatingActionButton (tooltip 'Add note') that opens AddNoteDialog and
///   calls NotesRepository.addNote. On ArgumentError show a SnackBar 'A title is required.'
/// - Body: a StreamBuilder over _notes:
///     error                -> Text('Could not load notes.')
///     no data yet          -> CircularProgressIndicator
///     empty list           -> Text('No notes yet')
///     otherwise            -> a ListView of ListTile(title, subtitle: body), each inside a
///                             Dismissible (key: ValueKey(note.id)) that calls deleteNote.
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key, required this.uid});

  final String uid;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // Created once, not in build (Week 6: a new stream on every rebuild restarts it). Given.
  late final Stream<List<Note>> _notes = context.read<NotesRepository>().watchNotes(widget.uid);

  Future<void> _add() async {
    // TODO(4): showDialog<(String, String)>(context: context, builder: (_) => const AddNoteDialog())
    //          then addNote(widget.uid, result.$1, result.$2).
    // Tip: read the repository and ScaffoldMessenger BEFORE the first await.
  }

  @override
  Widget build(BuildContext context) {
    // TODO(4)
    return const Scaffold(body: Center(child: Text('TODO: NotesScreen')));
  }
}

// These imports are used by the finished screen.
// ignore_for_file: unused_import, unused_element, unused_field
