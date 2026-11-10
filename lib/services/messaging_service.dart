import 'package:firebase_messaging/firebase_messaging.dart';

/// Part 6: push notifications with Firebase Cloud Messaging (FCM).
class MessagingService {
  MessagingService(this._messaging);

  final FirebaseMessaging _messaging;

  /// The topic every student subscribes to.
  static const topic = 'comp205';

  /// 1. await _messaging.requestPermission()  (Android 13+ shows a dialog)
  /// 2. if settings.authorizationStatus == AuthorizationStatus.denied -> return null
  /// 3. final token = await _messaging.getToken()
  /// 4. await _messaging.subscribeToTopic(topic), then return token
  Future<String?> init() async {
    // TODO(6)
    return null;
  }

  /// Calls [show] for every message that arrives while the app is open.
  /// In the foreground Android does not show the notification itself.
  /// Listen to FirebaseMessaging.onMessage; use message.notification?.title / ?.body
  /// ('New message' and '' if they are null).
  void listenInForeground(void Function(String title, String body) show) {
    // TODO(6)
  }
}

// Remove this line when you are done:
// ignore_for_file: unused_field
