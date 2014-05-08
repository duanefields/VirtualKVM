#import <Foundation/Foundation.h>

@interface KVMBluetoothController : NSObject

+ (instancetype)sharedController;

- (void)setBluetoothEnabled:(BOOL)enabled;

@end
