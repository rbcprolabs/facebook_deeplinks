import 'dart:async';

import 'package:flutter/services.dart';

class FacebookDeeplinks {
  static const MethodChannel _methodChannel =
      const MethodChannel('ru.proteye/facebook_deeplinks/channel');
  final EventChannel _eventChannel =
      const EventChannel('ru.proteye/facebook_deeplinks/events');

  Future<dynamic> initFacebookDeeplinks() async {
    try {
      return _methodChannel.invokeMethod('initFacebookDeeplinks');
    } on PlatformException catch (e) {
      return "Failed to Invoke: '${e.message}'.";
    }
  }

  Stream<dynamic> receiveBroadcastStream() {
    return _eventChannel.receiveBroadcastStream();
  }
}
