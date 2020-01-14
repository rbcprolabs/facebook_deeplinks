import Flutter
import UIKit
import FacebookCore

public class SwiftFacebookDeeplinksPlugin: NSObject, FlutterPlugin {
  private let linkStreamHandler = LinkStreamHandler()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ru.proteye/facebook_deeplinks/channel", binaryMessenger: registrar.messenger())
    let streamChannel = FlutterEventChannel(name: "ru.proteye/facebook_deeplinks/events", binaryMessenger: registrar.messenger())
    let instance = SwiftFacebookDeeplinksPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    streamChannel.setStreamHandler(linkStreamHandler)
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    Settings.isAutoInitEnabled = true
    ApplicationDelegate.initializeSDK(nil)
    AppLinkUtility.fetchDeferredAppLink { (url, error) in
      if let error = error {
        print("Received error while fetching deferred app link %@", error)
      }
      if let url = url {
        self.linkStreamHandler.handleLink(url.absoluteString)
        if #available(iOS 10, *) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
          UIApplication.shared.openURL(url)
        }
      }
    }
    return true
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    return linkStreamHandler.handleLink(url.absoluteString)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "initFacebookDeeplinks" else {
      result(FlutterMethodNotImplemented)
      return
    }
  }
}

private class LinkStreamHandler:NSObject, FlutterStreamHandler {
  
  var eventSink: FlutterEventSink?
  
  // links will be added to this queue until the sink is ready to process them
  var queuedLinks = [String]()
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    queuedLinks.forEach({ events($0) })
    queuedLinks.removeAll()
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
  
  func handleLink(_ link: String) -> Bool {
    guard let eventSink = eventSink else {
      queuedLinks.append(link)
      return false
    }
    eventSink(link)
    return true
  }
}
