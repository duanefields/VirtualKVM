#import "KVMStatusItem.h"

@interface KVMStatusItem ()
@end


@implementation KVMStatusItem

+ (NSStatusItem *)statusItemWithMenu:(NSMenu *)menu {
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    statusItem.title = nil;
    statusItem.image = [NSImage imageNamed:@"StatusIcon"];
    statusItem.alternateImage = [NSImage imageNamed:@"StatusIcon"];
    statusItem.highlightMode = YES;
    statusItem.menu = menu;
    
    return statusItem;
}

@end
