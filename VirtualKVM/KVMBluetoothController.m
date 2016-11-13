#import "KVMBluetoothController.h"

// private methods from the Bluetooth Framework
void IOBluetoothPreferenceSetControllerPowerState(int state);

@implementation KVMBluetoothController

+ (instancetype)sharedController {
  static KVMBluetoothController *sharedInstance;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    sharedInstance = [KVMBluetoothController new];
  });

  return sharedInstance;
}

- (void)disableBluetooth {
  NSLog(@"Disabling Bluetooth.");
  IOBluetoothPreferenceSetControllerPowerState(NO);
}

- (void)enableBluetooth {
  NSLog(@"Enabling Bluetooth.");
  IOBluetoothPreferenceSetControllerPowerState(YES);
}

@end
