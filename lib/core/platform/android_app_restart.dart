import 'dart:io';

import 'package:flutter/services.dart';

abstract final class AndroidAppRestart {
  static const MethodChannel _channel = MethodChannel('fluxer_app/app_restart');

  static Future<void> restart() async {
    if (!Platform.isAndroid) {
      return;
    }
    await _channel.invokeMethod<void>('restart');
  }
}
