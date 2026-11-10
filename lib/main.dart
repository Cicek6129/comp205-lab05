import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/auth_repository.dart';
import 'data/notes_repository.dart';
import 'firebase_options.dart'; // created by `flutterfire configure` (Part 0) - not in git
import 'screens/notes_screen.dart';
import 'screens/sign_in_screen.dart';
import 'services/messaging_service.dart';

/// Runs when a message arrives while the app is in the background.
/// Must be a top-level function. Given.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message: ${message.notification?.title}');
}

final messengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  runApp(MultiProvider(
    providers: [
      Provider(create: (_) => AuthRepository(FirebaseAuth.instance)),
      Provider(create: (_) => NotesRepository(FirebaseFirestore.instance)),
      Provider(create: (_) => MessagingService(FirebaseMessaging.instance)),
    ],
    child: const StudyNotesApp(),
  ));
}

class StudyNotesApp extends StatelessWidget {
  const StudyNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Notes',
      scaffoldMessengerKey: messengerKey,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const AuthGate(),
    );
  }
}

/// Shows SignInScreen or NotesScreen, depending on the auth state. Given.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<User?> _user = context.read<AuthRepository>().authStateChanges();

  @override
  void initState() {
    super.initState();
    _setUpMessaging();
  }

  Future<void> _setUpMessaging() async {
    final messaging = context.read<MessagingService>();
    messaging.listenInForeground((title, body) {
      messengerKey.currentState?.showSnackBar(SnackBar(content: Text('$title\n$body')));
    });
    final token = await messaging.init();
    // Copy this token from the Debug Console for "Send test message" (Part 6).
    debugPrint('FCM token: $token');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snapshot.data;
        return user == null
            ? const SignInScreen()
            : NotesScreen(key: ValueKey(user.uid), uid: user.uid);
      },
    );
  }
}
