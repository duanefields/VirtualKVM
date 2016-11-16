#import "GVUserDefaults+KVMApp.h"

@implementation GVUserDefaults (KVMApp)

@dynamic toggleBluetooth;
@dynamic toggleTargetDisplayMode;
@dynamic toggleDisableSleep;
@dynamic toggleDisableIdleSleep;
    
- (NSDictionary *)setupDefaults {
  return @{
    @"toggleBluetooth": @YES,
    @"toggleTargetDisplayMode": @YES,
    @"toggleDisableSleep": @YES,
    @"toggleDisableIdleSleep":@NO,
  };
}

@end
