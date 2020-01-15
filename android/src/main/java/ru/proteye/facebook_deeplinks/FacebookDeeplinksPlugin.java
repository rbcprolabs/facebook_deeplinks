package ru.proteye.facebook_deeplinks;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FacebookDeeplinksPlugin */
public class FacebookDeeplinksPlugin implements FlutterPlugin, MethodCallHandler, StreamHandler {
  private static final String MESSAGES_CHANNEL = "ru.rbc.pro.marketing/facebook_deeplink/channel";
  private static final String EVENTS_CHANNEL = "ru.rbc.pro.marketing/facebook_deeplink/events";
  private BroadcastReceiver linksReceiver;
  private String url;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    FacebookDeeplinksPlugin instance = new FacebookDeeplinksPlugin();
    final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), MESSAGES_CHANNEL);
    channel.setMethodCallHandler(instance);
    final EventChannel streamChannel = new EventChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), EVENTS_CHANNEL);
    streamChannel.setStreamHandler(instance);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    // Detect if we've been launched in background
    if (registrar.activity() == null) {
      return;
    }
    FacebookDeeplinksPlugin instance = new FacebookDeeplinksPlugin();
    final MethodChannel channel = new MethodChannel(registrar.messenger(), MESSAGES_CHANNEL);
    channel.setMethodCallHandler(instance);
    final EventChannel streamChannel = new EventChannel(registrar.messenger(), EVENTS_CHANNEL);
    streamChannel.setStreamHandler(instance);
    registrar.addNewIntentListener(instance);
  }

  private FacebookDeeplinksPlugin() {
    FacebookSdk.setAutoInitEnabled(true);
    FacebookSdk.fullyInitialize();
    AppLinkData.fetchDeferredAppLinkData(this, 
      new AppLinkData.CompletionHandler() {
        @Override
        public void onDeferredAppLinkDataFetched(AppLinkData appLinkData) {
          url = appLinkData.getTargetUri().getPath();
        }
      }
    );
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("initFacebookDeeplinks")) {
      if (url != null) {
        result.success(url);
      }
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onListen(Object args, final EventChannel.EventSink events) {
    linksReceiver = createChangeReceiver(events);
  }

  @Override
  public void onCancel(Object args) {
    linksReceiver = null;
  }

  @Override
  public boolean onNewIntent(Intent intent){
    if(intent.getAction() == android.content.Intent.ACTION_VIEW && linksReceiver != null) {
      linksReceiver.onReceive(this.getApplicationContext(), intent);
    }
    return false;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }

  private void handleIntent(Context context, Intent intent, Boolean initial) {
    String action = intent.getAction();
    String dataString = intent.getDataString();

    if (Intent.ACTION_VIEW.equals(action)) {
      if (initial) initialLink = dataString;
      latestLink = dataString;
      if (changeReceiver != null) changeReceiver.onReceive(context, intent);
    }
  }

  private BroadcastReceiver createChangeReceiver(final EventChannel.EventSink events) {
    return new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        // NOTE: assuming intent.getAction() is Intent.ACTION_VIEW

        String dataString = intent.getDataString();

        if (dataString == null) {
          events.error("UNAVAILABLE", "Link unavailable", null);
        } else {
          events.success(dataString);
        }
        ;
      }
    };
  }
}
