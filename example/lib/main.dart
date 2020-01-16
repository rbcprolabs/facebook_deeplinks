import 'dart:async';

import 'package:flutter/material.dart';
import 'package:facebook_deeplinks/facebook_deeplinks.dart';

// Example deeplink: fb1900783610055777://test

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

    deeplinkUrl = await FacebookDeeplinks().initFacebookDeeplinks();
    FacebookDeeplinks().onDeeplinkReceived.listen(_onRedirected);

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
                  print('GET DEEPLINK!');
                  var deeplinkUrl =
                      await FacebookDeeplinks().initFacebookDeeplinks();
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
    print('URI: $uri');
    setState(() {
      _deeplinkUrl = uri;
    });
  }
}
