#import "KVMStatusItem.h"

@interface KVMStatusItem ()
@end


@implementation KVMStatusItem

+ (NSStatusItem *)statusItemWithMenu:(NSMenu *)menu {
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    statusItem.title = nil;
    NSImage *icon = [NSImage imageNamed:@"StatusIcon"];
    icon.template = true;
    statusItem.image = icon;
    statusItem.alternateImage = icon;
    statusItem.highlightMode = YES;
    statusItem.menu = menu;
    
    return statusItem;
}

@end
