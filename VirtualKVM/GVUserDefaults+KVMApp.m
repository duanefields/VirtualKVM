#import "GVUserDefaults+KVMApp.h"

@implementation GVUserDefaults (KVMApp)

@dynamic toggleBluetooth;
@dynamic toggleTargetDisplayMode;
@dynamic toggleDisableSleep;

- (NSDictionary *)setupDefaults {
<<<<<<< HEAD
    return @{
             @"toggleBluetooth": @YES,
             @"toggleTargetDisplayMode": @YES,
             @"toggleDisableSleep": @YES,
            };
=======
  return @{
    @"toggleBluetooth": @YES,
    @"toggleTargetDisplayMode": @YES,
  };
>>>>>>> duanefields/master
}

@end
