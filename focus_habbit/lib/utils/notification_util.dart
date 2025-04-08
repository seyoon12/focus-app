import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';

class NotificationUtil {
  static const MethodChannel _platform = MethodChannel('com.example.dnd');

  static Future<void> openDndSettings() async {
    const intent = AndroidIntent(
      action: 'android.settings.NOTIFICATION_POLICY_ACCESS_SETTINGS',
    );
    await intent.launch();
  }

  static Future<void> enableDndMode() async {
    try {
      await _platform.invokeMethod('enableDnd');
    } on PlatformException catch (e) {
      print('DND ON 실패: ${e.message}');
    }
  }

  static Future<void> disableDndMode() async {
    try {
      await _platform.invokeMethod('disableDnd');
    } on PlatformException catch (e) {
      print('DND OFF 실패: ${e.message}');
    }
  }
}
