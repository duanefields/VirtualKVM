#import "GVUserDefaults.h"

@interface GVUserDefaults (KVMApp)

@property (nonatomic) BOOL toggleBluetooth;
@property (nonatomic) BOOL toggleTargetDisplayMode;

- (NSDictionary *)setupDefaults;

@end
