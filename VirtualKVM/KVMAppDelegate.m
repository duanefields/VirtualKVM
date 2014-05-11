#import "KVMAppDelegate.h"
#import "KVMStatusItem.h"
#import "KVMController.h"
#import "GVUserDefaults+KVMApp.h"

@interface KVMAppDelegate ()

@property (nonatomic) IBOutlet NSStatusItem *statusItem;
@property (nonatomic) IBOutlet NSMenu *menu;
@property (nonatomic) IBOutlet KVMController *controller;
@property (weak) IBOutlet NSMenuItem *toggleBluetoothMenuItem;
@property (weak) IBOutlet NSMenuItem *toggleDisplayMenuItem;

@end

@implementation KVMAppDelegate

- (void)awakeFromNib {
    self.toggleBluetoothMenuItem.state = [GVUserDefaults standardUserDefaults].toggleBluetooth ? NSOnState : NSOffState;
    self.toggleDisplayMenuItem.state = [GVUserDefaults standardUserDefaults].toggleTargetDisplayMode ? NSOnState : NSOffState;
    
    self.statusItem = [KVMStatusItem statusItemWithMenu:self.menu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //
}

@end
