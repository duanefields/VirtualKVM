#import "KVMAppDelegate.h"
#import "KVMStatusItem.h"
#import "KVMController.h"
#import "GVUserDefaults+KVMApp.h"

@interface CustomLogFormatter : NSObject <DDLogFormatter>

@end

@implementation CustomLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
  NSString *string = [NSString stringWithFormat:@"%@ — %@ | %@ (%@:%@)", logMessage->_timestamp, logMessage->_message, logMessage->_function, logMessage->_fileName, @(logMessage->_line)];
  
  switch (logMessage->_flag) {
    case DDLogFlagError:
      string = [NSString stringWithFormat:@"❤️ %@", string];
      break;
    case DDLogFlagWarning:
      string = [NSString stringWithFormat:@"💛 %@", string];
      break;
    case DDLogFlagInfo:
      string = [NSString stringWithFormat:@"💙 %@", string];
      break;
    case DDLogFlagDebug:
      string = [NSString stringWithFormat:@"💚 %@", string];
      break;
    case DDLogFlagVerbose:
      string = [NSString stringWithFormat:@"💜 %@", string];
      break;
      
    default:
      string = [NSString stringWithFormat:@"🖤 %@", string];
      break;
  }
  
  return string;
}

@end

@interface KVMAppDelegate ()

@end
@implementation KVMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  
  DDFileLogger *fileLogger = [[DDFileLogger alloc]init];
  fileLogger.rollingFrequency = 432000; // 5 day rolling
  fileLogger.maximumFileSize = 0; //disable rolling due to filesize by setting to 0
 
    
  CustomLogFormatter *formatter = [CustomLogFormatter new];
  fileLogger.logFormatter = formatter;
  [DDTTYLogger sharedInstance].logFormatter = formatter;
  [DDASLLogger sharedInstance].logFormatter = formatter;
  
  [DDLog addLogger:fileLogger];
  
 
  //Don't use the older longer loggers (ASL & TTY) on macOS 10.12 or later
  // Causes log to be logged twice
  // See https://github.com/CocoaLumberjack/CocoaLumberjack/issues/905
  if (@available(macOS 10.12, *)) {
    [DDOSLogger sharedInstance].logFormatter = formatter;
    [DDLog addLogger:[DDOSLogger sharedInstance]];
  } else {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
  }
 
}

@end
