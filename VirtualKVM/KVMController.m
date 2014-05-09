#import "KVMController.h"
#import "KVMBluetoothController.h"

@interface KVMController ()
@property KVMThunderboltObserver *thunderboltObserver;
@end

@implementation KVMController

- (id)init {
    self = [super init];
    self.thunderboltObserver = [[KVMThunderboltObserver alloc] initWithDelegate:self];
    [self.thunderboltObserver startObserving];

    return self;
}

- (void)enableTargetDisplayMode {
    static NSAppleScript *script;
    if (script == nil) {
        script = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 144 using command down"];
    }
    
    NSDictionary *errorInfo = nil;
    [script executeAndReturnError:&errorInfo];
}

#pragma mark - Menu Options

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

#pragma mark - KVMThunderboltObserver

- (void)thunderboltObserverDeviceConnected:(KVMThunderboltObserver *)observer {
    NSLog(@"thunderbolt device connected");
    
    [self enableTargetDisplayMode];
    
    [[KVMBluetoothController sharedController] setBluetoothEnabled:NO];
}

- (void)thunderboltObserverDeviceDisconnected:(KVMThunderboltObserver *)observer {
    NSLog(@"thunderbolt device disconnected");

    // system will automatically disable target display mode
    
    [[KVMBluetoothController sharedController] setBluetoothEnabled:YES];
}

@end
