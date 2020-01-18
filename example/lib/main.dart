import 'dart:async';

import 'package:flutter/material.dart';
import 'package:facebook_deeplinks/facebook_deeplinks.dart';

// Example deeplink: fb1900783610066589://test

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _deeplinkUrl = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String deeplinkUrl;

    var facebookDeeplinks = FacebookDeeplinks();
    facebookDeeplinks.onDeeplinkReceived.listen(_onRedirected);
    deeplinkUrl = await facebookDeeplinks.getInitialUrl();

    if (!mounted) return;

    _onRedirected(deeplinkUrl);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text('Deeplink URL: $_deeplinkUrl'),
              RaisedButton(
                child: Text('GET DEEPLINK'),
                onPressed: () async {
                  var deeplinkUrl = await FacebookDeeplinks().getInitialUrl();
                  _onRedirected(deeplinkUrl);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onRedirected(String uri) {
    setState(() {
      _deeplinkUrl = uri;
    });
  }
}
