#import "KVMAppDelegate.h"
#import "KVMStatusItem.h"
#import "KVMController.h"

@interface KVMAppDelegate ()

@property (nonatomic) IBOutlet NSStatusItem *statusItem;
@property (nonatomic) IBOutlet NSMenu *menu;
@property (nonatomic) IBOutlet KVMController *controller;

@end

@implementation KVMAppDelegate

- (void)awakeFromNib {
    self.statusItem = [KVMStatusItem statusItemWithMenu:self.menu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //
}

@end
