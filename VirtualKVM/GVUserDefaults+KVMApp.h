#import "GVUserDefaults.h"

@interface GVUserDefaults (KVMApp)

@property (nonatomic) BOOL toggleBluetooth;
@property (nonatomic) BOOL toggleTargetDisplayMode;
@property (nonatomic) BOOL toggleDisableSleep;

- (NSDictionary *)setupDefaults;

@end
