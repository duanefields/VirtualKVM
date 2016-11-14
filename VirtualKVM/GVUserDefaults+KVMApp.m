#import "GVUserDefaults+KVMApp.h"

@implementation GVUserDefaults (KVMApp)

@dynamic toggleBluetooth;
@dynamic toggleTargetDisplayMode;
@dynamic toggleDisableSleep;

- (NSDictionary *)setupDefaults {
    return @{
             @"toggleBluetooth": @YES,
             @"toggleTargetDisplayMode": @YES,
             @"toggleDisableSleep": @YES,
            };
}

@end
