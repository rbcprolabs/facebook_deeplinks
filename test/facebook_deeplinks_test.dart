import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:facebook_deeplinks/facebook_deeplinks.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('ru.proteye/facebook_deeplinks/channel');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return 'https://example.com';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getInitialUrl', () async {
    expect(await FacebookDeeplinks().getInitialUrl(), 'https://example.com');
  });
}
