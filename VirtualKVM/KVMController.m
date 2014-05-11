#import "KVMController.h"
#import "KVMBluetoothController.h"
#import "GVUserDefaults+KVMApp.h"
#import "KVMStatusItem.h"

@interface KVMController ()
@property (nonatomic) KVMThunderboltObserver *thunderboltObserver;
@property (nonatomic) NSStatusItem *statusItem;

@property (nonatomic) IBOutlet NSMenu *menu;
@property (weak) IBOutlet NSMenuItem *toggleBluetoothMenuItem;
@property (weak) IBOutlet NSMenuItem *toggleDisplayMenuItem;
@property (weak) IBOutlet NSMenuItem *connectionStatusMenuItem;

@end

@implementation KVMController

- (id)init {
    self = [super init];
    self.thunderboltObserver = [[KVMThunderboltObserver alloc] initWithDelegate:self];
    [self.thunderboltObserver startObserving];

    return self;
}

- (void)awakeFromNib {
    self.toggleBluetoothMenuItem.state = [GVUserDefaults standardUserDefaults].toggleBluetooth ? NSOnState : NSOffState;
    self.toggleDisplayMenuItem.state = [GVUserDefaults standardUserDefaults].toggleTargetDisplayMode ? NSOnState : NSOffState;
    self.connectionStatusMenuItem.title = @"Status: Unknown";
    
    self.statusItem = [KVMStatusItem statusItemWithMenu:self.menu];
}

#pragma mark - Menu Actions

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

#pragma mark - KVMThunderboltObserverDelegate

- (void)thunderboltObserverDeviceConnected:(KVMThunderboltObserver *)observer {
    NSLog(@"thunderbolt device connected");
    [self updateConnectionState:YES];
    
    if ([GVUserDefaults standardUserDefaults].toggleTargetDisplayMode) {
        [self enableTargetDisplayMode];
    }

    if ([GVUserDefaults standardUserDefaults].toggleBluetooth) {
        [[KVMBluetoothController sharedController] setBluetoothEnabled:NO];
    }
}

- (void)thunderboltObserverDeviceDisconnected:(KVMThunderboltObserver *)observer {
    NSLog(@"thunderbolt device disconnected");
    [self updateConnectionState:NO];

    if ([GVUserDefaults standardUserDefaults].toggleTargetDisplayMode) {
        // system will automatically disable target display mode
    }
    
    if ([GVUserDefaults standardUserDefaults].toggleBluetooth) {
        [[KVMBluetoothController sharedController] setBluetoothEnabled:YES];
    }
}

- (void)thunderboltObserver:(KVMThunderboltObserver *)observer isInitiallyConnected:(BOOL)connected {
    [self updateConnectionState:connected];
}

- (void)updateConnectionState:(BOOL)connected {
    self.connectionStatusMenuItem.title = [NSString stringWithFormat:@"Status: %@", connected ? @"Connected" : @"Not Connected"];
}

#pragma mark - Helpers

- (void)enableTargetDisplayMode {
    static NSAppleScript *script;
    if (script == nil) {
        script = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 144 using command down"];
    }
    
    NSDictionary *errorInfo = nil;
    [script executeAndReturnError:&errorInfo];
}


@end
