import Flutter
import UIKit
import FBSDKCoreKit

let MESSAGES_CHANNEL = "ru.proteye/facebook_deeplinks/channel"
let EVENTS_CHANNEL = "ru.proteye/facebook_deeplinks/events"

public class SwiftFacebookDeeplinksPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  var _eventSink: FlutterEventSink?
  var _initialUrl: String = ""
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
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]
  ) -> Bool {
    if let url = launchOptions[.url] as? URL {
      _initialUrl = url.absoluteString
      self.handleLink(url.absoluteString)
    }

    Settings.isAutoInitEnabled = true
    ApplicationDelegate.initializeSDK(nil)
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
    return self.handleLink(url.absoluteString)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "initialUrl" {
      result(_initialUrl)
    } else {
      result(FlutterMethodNotImplemented)
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
