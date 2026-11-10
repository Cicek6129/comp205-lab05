// Placeholder for CI only. The real lib/firebase_options.dart is created by
// `flutterfire configure` and is NOT committed (see .gitignore).
// The CI workflow copies this file to lib/ so that `flutter analyze` succeeds.
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'ci-placeholder',
        appId: 'ci-placeholder',
        messagingSenderId: 'ci-placeholder',
        projectId: 'ci-placeholder',
      );
}
