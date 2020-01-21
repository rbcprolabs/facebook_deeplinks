# Facebook deeplinks

A flutter plugin to get facebook deeplinks and transferring them to the flutter application.

## Install

```yaml
dependencies:
  facebook_deeplinks: ^0.1.0
```

## Permission

### For Android

Open your `android/app/src/main/res/values/strings.xml` file and add the following lines (remember to replace [APP_ID] with your actual app ID):

```xml
<string name="facebook_app_id">[APP_ID]</string>
<string name="fb_login_protocol_scheme">fb[APP_ID]</string>
```

You need to declare at least one of the two intent filters in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
  <!-- ... other tags -->
  <application ...>
    <activity ...>
      <!-- ... other tags -->

      <!-- Deep Links -->
      <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <!-- Accepts URIs that begin with YOUR_SCHEME://YOUR_HOST -->
        <data
          android:scheme="@string/fb_login_protocol_scheme"
          android:host="[YOUR_HOST]" />
      </intent-filter>
    </activity>
    <!-- Facebook ID -->
    <meta-data
      android:name="com.facebook.sdk.ApplicationId"
      android:value="@string/facebook_app_id" />
    
    <!-- ... other tags -->
  </application>
</manifest>
```

The `android:host` attribute is optional for Deep Links.

### For iOS

For **Custom URL schemes** you need to declare the scheme in
`ios/Runner/Info.plist` (or through Xcode's Target Info editor,
under URL Types):

```xml
<!-- ... other tags -->
<plist>
<dict>
  <!-- ... other tags -->
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>fb[APP_ID]</string>
      </array>
    </dict>
  </array>
  <key>FacebookAppID</key>
  <string>[APP_ID]</string>
  <key>FacebookDisplayName</key>
  <string>[APP_NAME]</string>
  <!-- ... other tags -->
</dict>
</plist>
```

This allows for your app to be started from `YOUR_SCHEME://ANYTHING` links.

## Usage

`FacebookDeeplinks` is singleton class.

Example the code:

```dart
import 'dart:async';
import 'dart:io';

import 'package:facebook_deeplinks/facebook_deeplinks.dart';

// ...

  String _deeplinkUrl = 'Unknown';

  Future<void> initPlatformState() async {
    FacebookDeeplinks().onDeeplinkReceived.listen(_onRedirected);
    String initialUrl = await FacebookDeeplinks().getInitialUrl();

    if (!mounted) return;

    _onRedirected(initialUrl);
  }

  void _onRedirected(String url) {
    setState(() {
      _deeplinkUrl = url;
    });
  }

// ...
```