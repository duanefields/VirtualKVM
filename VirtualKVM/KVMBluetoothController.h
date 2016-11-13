#import <Foundation/Foundation.h>

@interface KVMBluetoothController : NSObject

+ (instancetype)sharedController;

- (void)disableBluetooth;
- (void)enableBluetooth;

@end
