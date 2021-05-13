#import "WhiteboardPlugin.h"
#if __has_include(<whiteboard/whiteboard-Swift.h>)
#import <whiteboard/whiteboard-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "whiteboard-Swift.h"
#endif

@implementation WhiteboardPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWhiteboardPlugin registerWithRegistrar:registrar];
}
@end
