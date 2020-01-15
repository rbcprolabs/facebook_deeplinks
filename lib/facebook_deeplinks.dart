import 'dart:async';

import 'package:flutter/services.dart';

class FacebookDeeplinks {
  factory FacebookDeeplinks() {
    if (_singleton == null) {
      _singleton = FacebookDeeplinks._();
    }

    return _singleton;
  }

  FacebookDeeplinks._();

  static FacebookDeeplinks _singleton;

  Stream<String> _onDeeplinkReceived;

  static const MethodChannel _methodChannel =
      const MethodChannel('ru.proteye/facebook_deeplinks/channel');
  final EventChannel _eventChannel =
      const EventChannel('ru.proteye/facebook_deeplinks/events');

  Future<String> initFacebookDeeplinks() async {
    try {
      return _methodChannel.invokeMethod('initFacebookDeeplinks');
    } on PlatformException catch (e) {
      return "Failed to Invoke: '${e.message}'.";
    }
  }

  Stream<String> get onDeeplinkReceived {
    if (_onDeeplinkReceived == null) {
      _onDeeplinkReceived = _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => event.toString());
    }

    return _onDeeplinkReceived;
  }
}
