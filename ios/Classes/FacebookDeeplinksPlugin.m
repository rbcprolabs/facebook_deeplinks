#import "FacebookDeeplinksPlugin.h"
#if __has_include(<facebook_deeplinks/facebook_deeplinks-Swift.h>)
#import <facebook_deeplinks/facebook_deeplinks-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "facebook_deeplinks-Swift.h"
#endif

@implementation FacebookDeeplinksPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFacebookDeeplinksPlugin registerWithRegistrar:registrar];
}
@end
