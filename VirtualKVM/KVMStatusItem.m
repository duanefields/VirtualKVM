#import "KVMStatusItem.h"

@interface KVMStatusItem ()
@end


@implementation KVMStatusItem

+ (NSStatusItem *)statusItemWithMenu:(NSMenu *)menu {
  NSImage *icon = [NSImage imageNamed:@"StatusIcon"];
  icon.template = true;

  NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  statusItem.title = nil;
  statusItem.image = icon;
  statusItem.alternateImage = icon;
  statusItem.highlightMode = YES;
  statusItem.menu = menu;

  return statusItem;
}

@end
