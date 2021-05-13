
import 'dart:async';

import 'package:flutter/services.dart';

class Whiteboard {
  static const MethodChannel _channel =
      const MethodChannel('whiteboard');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
