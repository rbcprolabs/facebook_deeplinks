import Flutter
import UIKit
import FBSDKCoreKit

let MESSAGES_CHANNEL = "ru.proteye/facebook_deeplinks/channel"
let EVENTS_CHANNEL = "ru.proteye/facebook_deeplinks/events"

public class SwiftFacebookDeeplinksPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  var _eventSink: FlutterEventSink?
  
  // links will be added to this queue until the sink is ready to process them
  var _queuedLinks = [String]()
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftFacebookDeeplinksPlugin()
    
    let channel = FlutterMethodChannel(name: MESSAGES_CHANNEL, binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    let streamChannel = FlutterEventChannel(name: EVENTS_CHANNEL, binaryMessenger: registrar.messenger())
    streamChannel.setStreamHandler(instance)
    
    registrar.addApplicationDelegate(instance)
  }

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    Settings.isAutoInitEnabled = true
    ApplicationDelegate.initializeSDK(nil)
    print("START APP!!!")
    if let url = launchOptions?[.url] as? URL {
      handleLink(url.absoluteString)
    }
    AppLinkUtility.fetchDeferredAppLink { (url, error) in
      if let error = error {
        print("Received error while fetching deferred app link %@", error)
      }
      if let url = url {
        self.handleLink(url.absoluteString)
        if #available(iOS 10, *) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
          UIApplication.shared.openURL(url)
        }
      }
    }
    return true
  }

  public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return handleLink(url.absoluteString)
  }

  public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    if (userActivity.activityType == NSUserActivityTypeBrowsingWeb) {
      if let url = userActivity.webpageURL as URL? {
        handleLink(url.absoluteString)
      }
      return true
    }
    return false
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "initFacebookDeeplinks" else {
      result(FlutterMethodNotImplemented)
      return
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
    _eventSink = eventSink
    _queuedLinks.forEach({ eventSink($0) })
    _queuedLinks.removeAll()
    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    _eventSink = nil
    return nil
  }
  
  private func handleLink(_ link: String) -> Bool {
    guard let eventSink = _eventSink else {
      _queuedLinks.append(link)
      return false
    }
    eventSink(link)
    return true
  }
}
