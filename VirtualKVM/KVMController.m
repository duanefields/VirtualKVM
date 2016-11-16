#import "KVMController.h"
#import "KVMBluetoothController.h"
#import "GVUserDefaults+KVMApp.h"
#import "KVMStatusItem.h"
#import <IOKit/pwr_mgt/IOPMLib.h>
#include <sys/types.h>
#include <sys/sysctl.h>

@interface KVMController ()

@property (nonatomic, strong) KVMThunderboltObserver *thunderboltObserver;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic) IOPMAssertionID sleepAssertion;
@property (nonatomic) BOOL isClient;

@property (nonatomic) IBOutlet NSMenu *menu;
@property (weak) IBOutlet NSMenuItem *toggleBluetoothMenuItem;
@property (weak) IBOutlet NSMenuItem *toggleDisplayMenuItem;
@property (weak) IBOutlet NSMenuItem *toggleSleepMenuItem;
@property (weak) IBOutlet NSMenuItem *connectionStatusMenuItem;
@property (weak) IBOutlet NSMenuItem *toggleIdleSleepMenuItem;

@end

@implementation KVMController

+ (NSString *)machineModel {
  size_t len = 0;
  sysctlbyname("hw.model", NULL, &len, NULL, 0);

  if (len) {
    char *model = malloc(len * sizeof(char));
    sysctlbyname("hw.model", model, &len, NULL, 0);
    NSString *model_ns = [NSString stringWithUTF8String:model];
    free(model);
    NSLog(NSLocalizedString(@"Running on %@.", comment:nil), model_ns);
    return model_ns;
  }

  return @"Unknown";
}

- (id)init {
  self = [super init];
  self.isClient = [[KVMController machineModel] rangeOfString:@"iMac"].location == NSNotFound;
  self.thunderboltObserver = [[KVMThunderboltObserver alloc] initWithDelegate:self];
  [self.thunderboltObserver startObserving];

  return self;
}

- (NSString *)modeString {
  if (self.isClient) {
    return NSLocalizedString(@"Client Mode", comment:nil);
  } else {
    return NSLocalizedString(@"Host Mode", comment:nil);
  }
}

- (void)awakeFromNib {
  self.toggleBluetoothMenuItem.state = [GVUserDefaults standardUserDefaults].toggleBluetooth ? NSOnState : NSOffState;
  self.toggleDisplayMenuItem.state = [GVUserDefaults standardUserDefaults].toggleTargetDisplayMode ? NSOnState : NSOffState;
  self.toggleSleepMenuItem.state = [GVUserDefaults standardUserDefaults].toggleDisableSleep ? NSOnState : NSOffState;
 self.toggleIdleSleepMenuItem.state = [GVUserDefaults standardUserDefaults].toggleDisableIdleSleep ? NSOnState : NSOffState;

  self.connectionStatusMenuItem.title = [NSString stringWithFormat:@"%@: %@", [self modeString], NSLocalizedString(@"Initializing …", comment:"State when the application is initializing.")];

  if (self.isClient) {
    self.toggleDisplayMenuItem.enabled = NO;
    NSLog(NSLocalizedString(@"Running in %@.", comment:@"Example: Running in Client Mode."), [self modeString]);
  }

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

- (IBAction)toggleSleepOption:(id)sender {
  NSMenuItem *menuItem = (NSMenuItem *)sender;

  if (menuItem.state == NSOnState) {
    menuItem.state = NSOffState;
  } else {
    menuItem.state = NSOnState;
  }

    if (menuItem == self.toggleIdleSleepMenuItem) {
        
        [GVUserDefaults standardUserDefaults].toggleDisableIdleSleep = menuItem.state == NSOnState;

    } else if (menuItem == self.toggleSleepMenuItem) {
        
        [GVUserDefaults standardUserDefaults].toggleDisableSleep = menuItem.state == NSOnState;
    }
}

- (IBAction)quit:(id)sender {
  [[NSApplication sharedApplication] terminate:self];
}

#pragma mark - KVMThunderboltObserverDelegate

- (void)thunderboltObserverDeviceConnected:(KVMThunderboltObserver *)observer {
  NSLog(NSLocalizedString(@"Thunderbolt device connected.", comment:nil));
  [self updateConnectionState:YES];

  if ([GVUserDefaults standardUserDefaults].toggleTargetDisplayMode) {
    [self enableTargetDisplayMode];
  }

  if ([GVUserDefaults standardUserDefaults].toggleBluetooth) {
    if (self.isClient) {
      [[KVMBluetoothController sharedController] enableBluetooth];
    } else {
      [[KVMBluetoothController sharedController] disableBluetooth];
    }
  }
}

- (void)thunderboltObserverDeviceDisconnected:(KVMThunderboltObserver *)observer {
  NSLog(NSLocalizedString(@"Thunderbolt device disconnected.", comment:nil));
  [self updateConnectionState:NO];

  if ([GVUserDefaults standardUserDefaults].toggleTargetDisplayMode) {
    [self disableTargetDisplayMode];
  }

  if ([GVUserDefaults standardUserDefaults].toggleBluetooth) {
    if (self.isClient) {
      [[KVMBluetoothController sharedController] disableBluetooth];
    } else {
      [[KVMBluetoothController sharedController] enableBluetooth];
    }
  }
}

- (void)thunderboltObserver:(KVMThunderboltObserver *)observer isInitiallyConnected:(BOOL)connected {
  [self updateConnectionState:connected];

  if (connected) {
    if ([GVUserDefaults standardUserDefaults].toggleTargetDisplayMode) {
      [self enableTargetDisplayMode];
    }
  }
}

- (void)updateConnectionState:(BOOL)connected {
  self.connectionStatusMenuItem.title = [NSString stringWithFormat:@"%@: %@", [self modeString], connected ? NSLocalizedString(@"Connected", comment:nil) : NSLocalizedString(@"Not Connected", comment:nil)];
}

#pragma mark - Helpers

- (void)enableTargetDisplayMode {
  if ([self.thunderboltObserver isInTargetDisplayMode]) {
    return;
  }

  CGEventSourceRef src = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);

  CGEventRef f2d = CGEventCreateKeyboardEvent(src, 0x90, true);
  CGEventRef f2u = CGEventCreateKeyboardEvent(src, 0x90, false);

  CGEventSetFlags(f2d, kCGEventFlagMaskSecondaryFn | kCGEventFlagMaskCommand);
  CGEventSetFlags(f2u, kCGEventFlagMaskSecondaryFn | kCGEventFlagMaskCommand);

  CGEventTapLocation loc = kCGHIDEventTap;
  CGEventPost(loc, f2d);
  CGEventPost(loc, f2u);

  CFRelease(f2d);
  CFRelease(f2u);
  CFRelease(src);

    CFStringRef assertionType = nil;
    
    if ([GVUserDefaults standardUserDefaults].toggleTargetDisplayMode) {
        assertionType = kIOPMAssertPreventUserIdleDisplaySleep;
    } else {
        assertionType = kIOPMAssertPreventUserIdleSystemSleep;
    }
    CFStringRef reasonForActivity = (__bridge CFStringRef)@"In Target Display Mode";
    IOReturn success = IOPMAssertionCreateWithName(assertionType, kIOPMAssertionLevelOn, reasonForActivity, &_sleepAssertion);

    if (success == kIOReturnSuccess) {
      NSLog(NSLocalizedString(@"Sleep disabled.", comment:nil));
    } else {
      NSLog(NSLocalizedString(@"Error disabling sleep.", comment:nil));
    }
  
}

- (void)disableTargetDisplayMode {
  if (self.sleepAssertion != kIOPMNullAssertionID) {
    IOReturn success = IOPMAssertionRelease(self.sleepAssertion);

    if (success == kIOReturnSuccess) {
      NSLog(NSLocalizedString(@"Sleep enabled.", comment:nil));
    } else {
      NSLog(NSLocalizedString(@"Error enabling sleep.", comment:nil));
    }
  }
}

@end
