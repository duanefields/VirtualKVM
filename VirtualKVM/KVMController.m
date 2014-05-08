#import "KVMController.h"

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

- (IBAction)toggleDisplayMode:(id)sender {
    // todo check for thunderbolt connection?
    
    NSLog(@"toggling display mode");
    
    [self pressCommandF2];
}

- (void)pressCommandF2 {
    static NSAppleScript *script;
    if (script == nil) {
        script = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 144 using command down"];
    }
    
    NSDictionary *errorInfo = nil;
    [script executeAndReturnError:&errorInfo];
}

#pragma mark - KVMThunderboltObserver

- (void)thunderboltObserverDeviceConnected:(KVMThunderboltObserver *)observer {
    NSLog(@"thunderbolt device connected");
}

- (void)thunderboltObserverDeviceDisconnected:(KVMThunderboltObserver *)observer {
    NSLog(@"thunderbolt device disconnected");
}

@end
