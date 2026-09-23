import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:fluxer_fcm/fcm_ciphertext_hooks.dart';
import 'package:fluxer_fcm/fcm_message_mapper.dart';
import 'package:fluxer_fcm/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> fcmBackgroundMessageHandler(RemoteMessage message) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final String? ciphertext = extractFcmCiphertext(message.data);
    if (ciphertext == null) {
      return;
    }
    final FcmCiphertextHandler? handler = FcmCiphertextHooks.onCiphertext;
    if (handler == null) {
      return;
    }
    await handler(ciphertextBase64: ciphertext, backgroundMode: true);
  } on Object catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('[FCM] background handler failed: $error\n$stackTrace');
    }
  }
}
