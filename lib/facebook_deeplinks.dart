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

  Future<String> getInitialUrl() async {
    try {
      return _methodChannel.invokeMethod('initialUrl');
    } on PlatformException catch (e) {
      print("Failed to Invoke: '${e.message}'.");
      return '';
    }
  }

  Stream<String> get onDeeplinkReceived {
    if (_onDeeplinkReceived == null) {
      _onDeeplinkReceived =
          _eventChannel.receiveBroadcastStream().cast<String>();
    }
    return _onDeeplinkReceived;
  }
}
