#import "KVMController.h"
#import "KVMBluetoothController.h"
#import "GVUserDefaults+KVMApp.h"

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

- (IBAction)toggleTargetDisplayOption:(id)sender {
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    if (menuItem.state == NSOnState) {
        menuItem.state = NSOffState;
    } else {
        menuItem.state = NSOnState;
    }
    
    [GVUserDefaults standardUserDefaults].toggleTargetDisplayMode = menuItem.state == NSOnState;
}

- (IBAction)toggleBluetoothOption:(id)sender {
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    if (menuItem.state == NSOnState) {
        menuItem.state = NSOffState;
    } else {
        menuItem.state = NSOnState;
    }
    
    [GVUserDefaults standardUserDefaults].toggleBluetooth = menuItem.state == NSOnState;
}


- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

#pragma mark - KVMThunderboltObserver

- (void)thunderboltObserverDeviceConnected:(KVMThunderboltObserver *)observer {
    NSLog(@"thunderbolt device connected");
    
    if ([GVUserDefaults standardUserDefaults].toggleTargetDisplayMode) {
        [self enableTargetDisplayMode];
    }

    if ([GVUserDefaults standardUserDefaults].toggleBluetooth) {
        [[KVMBluetoothController sharedController] setBluetoothEnabled:NO];
    }
}

- (void)thunderboltObserverDeviceDisconnected:(KVMThunderboltObserver *)observer {
    NSLog(@"thunderbolt device disconnected");

    if ([GVUserDefaults standardUserDefaults].toggleTargetDisplayMode) {
        // system will automatically disable target display mode
    }
    
    if ([GVUserDefaults standardUserDefaults].toggleBluetooth) {
        [[KVMBluetoothController sharedController] setBluetoothEnabled:YES];
    }
}

@end
