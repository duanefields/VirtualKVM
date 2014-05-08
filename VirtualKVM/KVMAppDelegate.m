#import "KVMAppDelegate.h"
#import "KVMStatusItem.h"

@interface KVMAppDelegate ()

@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) IBOutlet NSMenu *menu;

@end

@implementation KVMAppDelegate

- (void)awakeFromNib {
    self.statusItem = [KVMStatusItem statusItemWithMenu:self.menu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
}

@end
