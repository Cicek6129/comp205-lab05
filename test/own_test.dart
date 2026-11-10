// Part 7: your own tests (at least 2, besides the example). They must test real code.
// Ideas: a 100-character title is accepted; body is trimmed; 'network-request-failed';
// signUp failure with whenCalling(...).thenThrow(...) (see lab05_test.dart).
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab05_study_notes/data/auth_repository.dart';

void main() {
  // Create one fake first: it makes FieldValue.serverTimestamp() work in tests.
  setUpAll(FakeFirebaseFirestore.new);

  test('example: messageFor maps weak-password', () {
    expect(AuthRepository.messageFor('weak-password'), contains('6 characters'));
  });

  // TODO(7): your tests
}
