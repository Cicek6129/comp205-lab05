// Lab 5 - provided tests. Do not change this file: the TAs grade with the original.
// No real Firebase is used: FakeFirebaseFirestore and MockFirebaseAuth run in memory.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab05_study_notes/data/auth_repository.dart';
import 'package:lab05_study_notes/data/notes_repository.dart';
import 'package:lab05_study_notes/models/note.dart';
import 'package:lab05_study_notes/screens/notes_screen.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:provider/provider.dart';

CollectionReference<Map<String, dynamic>> notesOf(FakeFirebaseFirestore db, String uid) =>
    db.collection('users').doc(uid).collection('notes');

void main() {
  // Create one fake first: it makes FieldValue.serverTimestamp() work in tests.
  setUpAll(FakeFirebaseFirestore.new);

  group('Part 1 - Note', () {
    test('fromFirestore reads id, title, body and createdAt', () {
      final note = Note.fromFirestore('n1', {
        'title': 'Exam',
        'body': 'Room B238',
        'createdAt': Timestamp.fromDate(DateTime(2026, 11, 11, 10)),
      });
      expect(note.id, 'n1');
      expect(note.title, 'Exam');
      expect(note.body, 'Room B238');
      expect(note.createdAt, DateTime(2026, 11, 11, 10));
    });

    test('fromFirestore: createdAt may be missing; a missing title is a FormatException', () {
      expect(Note.fromFirestore('n2', {'title': 'A', 'body': ''}).createdAt, isNull);
      expect(() => Note.fromFirestore('n3', {'body': 'no title'}), throwsFormatException);
    });

    test('toFirestore writes title, body and a server timestamp', () {
      final map = const Note(id: 'x', title: 'T', body: 'B').toFirestore();
      expect(map['title'], 'T');
      expect(map['body'], 'B');
      expect(map['createdAt'], isA<FieldValue>());
      expect(map.containsKey('id'), isFalse, reason: 'the id is the document id, not a field');
    });
  });

  group('Part 2 - AuthRepository', () {
    test('messageFor turns Firebase error codes into friendly messages', () {
      expect(AuthRepository.messageFor('invalid-email'), 'The email address is not valid.');
      expect(AuthRepository.messageFor('weak-password'), 'The password must be at least 6 characters.');
      expect(AuthRepository.messageFor('email-already-in-use'), 'An account already exists for this email.');
      expect(AuthRepository.messageFor('invalid-credential'), 'Wrong email or password.');
      expect(AuthRepository.messageFor('something-new'), 'Sign-in failed. Please try again.');
    });

    test('signUp creates and signs in the user (email trimmed)', () async {
      final repo = AuthRepository(MockFirebaseAuth());
      await repo.signUp('  ada@agu.edu.tr ', 'secret123');
      expect(repo.currentUser, isNotNull);
      expect(repo.currentUser!.email, 'ada@agu.edu.tr');
    });

    test('signIn failure becomes an AuthFailure with a friendly message', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'invalid-credential'));
      final repo = AuthRepository(auth);
      await expectLater(
        repo.signIn('ada@agu.edu.tr', 'wrong'),
        throwsA(isA<AuthFailure>().having((f) => f.message, 'message', 'Wrong email or password.')),
      );
    });

    test('signOut signs the user out', () async {
      final repo = AuthRepository(MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'u1')));
      expect(repo.currentUser, isNotNull);
      await repo.signOut();
      expect(repo.currentUser, isNull);
    });
  });

  group('Part 3 - NotesRepository', () {
    test('addNote stores a trimmed note that watchNotes delivers', () async {
      final db = FakeFirebaseFirestore();
      final repo = NotesRepository(db);
      await repo.addNote('u1', '  Lab 5  ', ' Firestore rules ');
      final notes = await repo.watchNotes('u1').first;
      expect(notes, hasLength(1));
      expect(notes.single.title, 'Lab 5');
      expect(notes.single.body, 'Firestore rules');
      expect((await notesOf(db, 'u1').get()).docs, hasLength(1), reason: 'path users/{uid}/notes');
    });

    test('addNote rejects an empty or too long title', () async {
      final repo = NotesRepository(FakeFirebaseFirestore());
      await expectLater(repo.addNote('u1', '   ', 'x'), throwsArgumentError);
      await expectLater(repo.addNote('u1', 'a' * 101, 'x'), throwsArgumentError);
    });

    test('watchNotes: newest first', () async {
      final db = FakeFirebaseFirestore();
      await notesOf(db, 'u1').add({'title': 'old', 'body': '', 'createdAt': Timestamp.fromDate(DateTime(2026, 11, 1))});
      await notesOf(db, 'u1').add({'title': 'new', 'body': '', 'createdAt': Timestamp.fromDate(DateTime(2026, 11, 9))});
      final notes = await NotesRepository(db).watchNotes('u1').first;
      expect(notes.map((n) => n.title), ['new', 'old']);
    });

    test('deleteNote removes the note', () async {
      final db = FakeFirebaseFirestore();
      final ref = await notesOf(db, 'u1').add({'title': 'x', 'body': '', 'createdAt': Timestamp.now()});
      await NotesRepository(db).deleteNote('u1', ref.id);
      expect((await notesOf(db, 'u1').get()).docs, isEmpty);
    });

    test("a user sees only their own notes", () async {
      final db = FakeFirebaseFirestore();
      final repo = NotesRepository(db);
      await repo.addNote('u1', 'mine', '');
      await repo.addNote('u2', 'theirs', '');
      final notes = await repo.watchNotes('u1').first;
      expect(notes.map((n) => n.title), ['mine']);
    });
  });

  group('Part 4 - NotesScreen', () {
    Future<void> pumpNotes(WidgetTester tester, FakeFirebaseFirestore db) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MultiProvider(
        providers: [
          Provider(create: (_) => NotesRepository(db)),
          Provider(create: (_) => AuthRepository(MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'u1')))),
        ],
        child: const MaterialApp(home: NotesScreen(uid: 'u1')),
      ));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('empty: title and "No notes yet"', (tester) async {
      await pumpNotes(tester, FakeFirebaseFirestore());
      expect(find.text('My Notes'), findsOneWidget);
      expect(find.text('No notes yet'), findsOneWidget);
    });

    testWidgets('shows the notes as list tiles', (tester) async {
      final db = FakeFirebaseFirestore();
      await notesOf(db, 'u1').add({'title': 'Read chapter 7', 'body': 'Firestore', 'createdAt': Timestamp.now()});
      await pumpNotes(tester, db);
      expect(find.widgetWithText(ListTile, 'Read chapter 7'), findsOneWidget);
      expect(find.text('Firestore'), findsOneWidget);
    });

    testWidgets('the Add note button opens the dialog and saves a note', (tester) async {
      final db = FakeFirebaseFirestore();
      await pumpNotes(tester, db);
      await tester.tap(find.byTooltip('Add note'));
      await tester.pumpAndSettle();
      expect(find.text('New note'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Quiz on Friday');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Quiz on Friday'), findsOneWidget);
      expect((await notesOf(db, 'u1').get()).docs, hasLength(1));
    });
  });
}
