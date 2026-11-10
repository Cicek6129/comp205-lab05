import 'package:cloud_firestore/cloud_firestore.dart';

/// Part 1: one note, stored at users/{uid}/notes/{noteId}.
class Note {
  const Note({required this.id, required this.title, required this.body, this.createdAt});

  final String id;
  final String title;
  final String body;

  /// Null for a moment after you add a note: the server has not set the time yet.
  final DateTime? createdAt;

  /// Builds a Note from a Firestore document (its id and its data map).
  /// - title and body must be Strings, otherwise throw a FormatException.
  /// - createdAt is a Timestamp (use .toDate()) - or missing/null: then createdAt is null.
  factory Note.fromFirestore(String id, Map<String, dynamic> data) {
    // TODO(1)
    throw UnimplementedError('Note.fromFirestore');
  }

  /// The map written to Firestore: title, body and
  /// 'createdAt': FieldValue.serverTimestamp() (the server sets the time).
  /// The id is NOT a field - it is the document id.
  Map<String, dynamic> toFirestore() {
    // TODO(1)
    throw UnimplementedError('Note.toFirestore');
  }
}

// Remove this line when you are done:
// ignore_for_file: unused_import
