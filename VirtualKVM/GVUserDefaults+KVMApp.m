#import "GVUserDefaults+KVMApp.h"

@implementation GVUserDefaults (KVMApp)

@dynamic toggleBluetooth;
@dynamic toggleTargetDisplayMode;

- (NSDictionary *)setupDefaults {
  return @{
    @"toggleBluetooth": @YES,
    @"toggleTargetDisplayMode": @YES,
  };
}

@end
