#import "KVMAppDelegate.h"
#import "KVMStatusItem.h"
#import "KVMController.h"
#import "GVUserDefaults+KVMApp.h"
#import "KVMSystemProfiler.h"
@import SBObjectiveCWrapper;

@interface KVMAppDelegate ()

@end
@implementation KVMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
 
  [[Uiltites shared]setupLogging];
  
  SBLogInfo(@"App version: %@", [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleVersionKey]);
  SBLogVerbose(@"Display info: %@", [KVMSystemProfiler dataTypes:@[@"SPDisplaysDataType"]].firstObject);
  SBLogVerbose(@"Thunderbolt info: %@", [KVMSystemProfiler dataTypes:@[@"SPThunderboltDataType"]].firstObject);
}

@end
