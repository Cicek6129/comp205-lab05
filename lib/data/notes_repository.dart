import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note.dart';

/// Part 3: the notes of one user in Cloud Firestore.
///
///   users/{uid}/notes/{noteId}  { title, body, createdAt }
class NotesRepository {
  NotesRepository(this._db);

  final FirebaseFirestore _db;

  /// The notes collection of one user. Given.
  CollectionReference<Map<String, dynamic>> _notes(String uid) =>
      _db.collection('users').doc(uid).collection('notes');

  /// Live list of the user's notes, newest first:
  /// orderBy('createdAt', descending: true), .snapshots(), then map every
  /// snapshot to a `List<Note>` with Note.fromFirestore(doc.id, doc.data()).
  Stream<List<Note>> watchNotes(String uid) {
    // TODO(3)
    throw UnimplementedError('watchNotes');
  }

  /// Adds a note. Title and body are trimmed. Throws an ArgumentError if the
  /// trimmed title is empty or longer than 100 characters.
  Future<void> addNote(String uid, String title, String body) async {
    // TODO(3)
    throw UnimplementedError('addNote');
  }

  Future<void> deleteNote(String uid, String noteId) async {
    // TODO(3)
    throw UnimplementedError('deleteNote');
  }
}

// Remove this line when you are done:
// ignore_for_file: unused_element
