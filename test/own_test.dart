// Part 7: your own tests (at least 2, besides the example). They must test real code.
// Ideas: a 100-character title is accepted; body is trimmed; 'network-request-failed';
// signUp failure with whenCalling(...).thenThrow(...) (see lab05_test.dart).
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab05_study_notes/data/auth_repository.dart';
import 'package:lab05_study_notes/data/notes_repository.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  // Create one fake first: it makes FieldValue.serverTimestamp() work in tests.
  setUpAll(FakeFirebaseFirestore.new);

  test('example: messageFor maps weak-password', () {
    expect(AuthRepository.messageFor('weak-password'), contains('6 characters'));
  });

  // TODO(7): your tests
  test('messageFor maps network-request-failed and the old sign-in codes', () {
    expect(AuthRepository.messageFor('network-request-failed'), 'No connection. Check your network.');
    expect(AuthRepository.messageFor('wrong-password'), 'Wrong email or password.');
    expect(AuthRepository.messageFor('user-not-found'), 'Wrong email or password.');
  });

  test('addNote accepts a title of exactly 100 characters (boundary)', () async {
    final repo = NotesRepository(FakeFirebaseFirestore());
    await repo.addNote('u1', 'a' * 100, 'x');
    final notes = await repo.watchNotes('u1').first;
    expect(notes.single.title, hasLength(100));
  });

  test('addNote trims the body and gives the note a server timestamp', () async {
    final repo = NotesRepository(FakeFirebaseFirestore());
    await repo.addNote('u1', 'Quiz', '   chapter 5   ');
    final note = (await repo.watchNotes('u1').first).single;
    expect(note.body, 'chapter 5');
    expect(note.createdAt, isNotNull);
  });

  test('signUp with an existing email becomes a friendly AuthFailure', () async {
    final auth = MockFirebaseAuth();
    whenCalling(Invocation.method(#createUserWithEmailAndPassword, null))
        .on(auth)
        .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
    final repo = AuthRepository(auth);
    await expectLater(
      repo.signUp('ada@agu.edu.tr', 'secret123'),
      throwsA(isA<AuthFailure>().having((f) => f.message, 'message', 'An account already exists for this email.')),
    );
    expect(repo.currentUser, isNull);
  });
}