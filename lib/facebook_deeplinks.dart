import 'dart:async';

import 'package:flutter/services.dart';

class FacebookDeeplinks {
  static const MethodChannel _channel =
      const MethodChannel('ru.proteye/facebook_deeplinks/channel');
  final EventChannel _stream =
      const EventChannel('ru.proteye/facebook_deeplinks/events');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
