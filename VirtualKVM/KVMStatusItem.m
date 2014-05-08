#import "KVMStatusItem.h"

@interface KVMStatusItem ()
@end


@implementation KVMStatusItem

+ (NSStatusItem *)statusItemWithMenu:(NSMenu *)menu {
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    statusItem.title = @"KVM";
    statusItem.image = [NSImage imageNamed:@"logo"];
    statusItem.alternateImage = [NSImage imageNamed:@"logo-alt"];
    statusItem.highlightMode = YES;
    statusItem.menu = menu;
    
    return statusItem;
}

@end
