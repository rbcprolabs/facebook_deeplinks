#import "FacebookDeeplinksPlugin.h"
#if __has_include(<facebook_deeplinks/facebook_deeplinks-Swift.h>)
#import <facebook_deeplinks/facebook_deeplinks-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "facebook_deeplinks-Swift.h"
#endif

// @implementation FacebookDeeplinksPlugin
// + (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
//  [SwiftFacebookDeeplinksPlugin registerWithRegistrar:registrar];
// }
// @end

static NSString *const MESSAGES_CHANNEL = @"ru.proteye/facebook_deeplinks/channel";
static NSString *const EVENTS_CHANNEL = @"ru.proteye/facebook_deeplinks/events";

@interface FacebookDeeplinksPlugin () <FlutterStreamHandler>
@property(nonatomic, copy) NSString *initialUrl;
@end

@implementation FacebookDeeplinksPlugin {
    FlutterEventSink _eventSink;
    NSMutableArray *_queuedLinks;
}

static id _instance;

+ (FacebookDeeplinksPlugin *)sharedInstance {
    if (_instance == nil) {
        _instance = [[FacebookDeeplinksPlugin alloc] init];
    }
    return _instance;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FacebookDeeplinksPlugin *instance = [FacebookDeeplinksPlugin sharedInstance];

    FlutterMethodChannel *channel =
        [FlutterMethodChannel methodChannelWithName:MESSAGES_CHANNEL
                                    binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:instance channel:channel];

    FlutterEventChannel *chargingChannel =
        [FlutterEventChannel eventChannelWithName:EVENTS_CHANNEL
                                binaryMessenger:[registrar messenger]];
    [chargingChannel setStreamHandler:instance];

    [registrar addApplicationDelegate:instance];
}

// - (void)setLatestLink:(NSString *)latestLink {
//   static NSString *key = @"latestLink";

//   [self willChangeValueForKey:key];
//   _latestLink = [latestLink copy];
//   [self didChangeValueForKey:key];

//   if (_eventSink) _eventSink(_latestLink);
// }

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSURL *url = (NSURL *)launchOptions[UIApplicationLaunchOptionsURLKey];
    self.initialUrl = [url absoluteString];
    [self handleLink:self.initialUrl];

    if (launchOptions[UIApplicationLaunchOptionsURLKey] == nil) {
        [FBSDKSettings setAutoInitEnabled:YES];
        [FBSDKApplicationDelegate initializeSDK:nil];
        [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
            if (error) {
                NSLog(@"Received error while fetching deferred app link %@", error);
            }
            if (url) {
                self.initialUrl = [url absoluteString];
                [self handleLink:self.initialUrl];
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
    }
  
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return [self handleLink:[url absoluteString]];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"initialUrl" isEqualToString:call.method]) {
        result(self.initialUrl);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)eventSink {
    _eventSink = eventSink;
//    _queuedLinks.forEach({ _eventSink($0) });
//    _queuedLinks.removeAll();
    return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (BOOL)handleLink:(NSString*) link {
    if (_queuedLinks == nil) {
        _queuedLinks = [NSMutableArray array];
    }
    if (_eventSink == nil) {
        if (link) [_queuedLinks addObject: link];
        return NO;
    }
    _eventSink(link);
    return YES;
}

@end
