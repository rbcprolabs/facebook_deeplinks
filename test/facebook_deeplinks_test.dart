import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:facebook_deeplinks/facebook_deeplinks.dart';

void main() {
  const MethodChannel channel = MethodChannel('facebook_deeplinks');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FacebookDeeplinks.platformVersion, '42');
  });
}
