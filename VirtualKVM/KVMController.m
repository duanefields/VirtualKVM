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
@property (weak) IBOutlet NSMenuItem *connectionStatusMenuItem;

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
    NSLog(@"Running on %@.", model_ns);
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

- (void)awakeFromNib {
  self.toggleBluetoothMenuItem.state = [GVUserDefaults standardUserDefaults].toggleBluetooth ? NSOnState : NSOffState;
  self.toggleDisplayMenuItem.state = [GVUserDefaults standardUserDefaults].toggleTargetDisplayMode ? NSOnState : NSOffState;
  self.connectionStatusMenuItem.title = @"Status: Unknown";
  self.connectionStatusMenuItem.title = [NSString stringWithFormat:@"%@ Mode: Initializing", self.isClient ? @"Client" : @"Host"];

  if (self.isClient) {
    self.toggleDisplayMenuItem.enabled = NO;
    NSLog(@"Running in client mode");
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
    if (self.isClient) {
      [[KVMBluetoothController sharedController] enableBluetooth];
    } else {
      [[KVMBluetoothController sharedController] disableBluetooth];
    }
  }
}

- (void)thunderboltObserverDeviceDisconnected:(KVMThunderboltObserver *)observer {
  NSLog(@"thunderbolt device disconnected");
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
}

- (void)updateConnectionState:(BOOL)connected {
  self.connectionStatusMenuItem.title = [NSString stringWithFormat:@"%@ Mode: %@", self.isClient ? @"Client" : @"Host", connected ? @"Connected" : @"Not Connected"];
}

#pragma mark - Helpers

- (void)enableTargetDisplayMode {

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

  CFStringRef reasonForActivity = (__bridge CFStringRef)@"In Target Display Mode";
  IOReturn success = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep, kIOPMAssertionLevelOn, reasonForActivity, &_sleepAssertion);

  if (success == kIOReturnSuccess) {
    NSLog(@"Sleep disabled.");
  } else {
    NSLog(@"Error disabling sleep.");
  }
}

- (void)disableTargetDisplayMode {
  IOReturn success = IOPMAssertionRelease(self.sleepAssertion);

  if (success == kIOReturnSuccess) {
    NSLog(@"Sleep enabled.");
  } else {
    NSLog(@"Error enabling sleep.");
  }
}

@end
