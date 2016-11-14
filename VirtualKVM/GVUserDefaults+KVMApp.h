#import "GVUserDefaults.h"

@interface GVUserDefaults (KVMApp)

@property (nonatomic) BOOL toggleBluetooth;
@property (nonatomic) BOOL toggleTargetDisplayMode;
<<<<<<< HEAD
@property (nonatomic) BOOL toggleDisableSleep;
=======

>>>>>>> duanefields/master
- (NSDictionary *)setupDefaults;

@end
