#import "KVMThunderboltObserver.h"
#import "KVMSystemProfiler.h"

static NSTimeInterval const kTimeInterval = 2.0;

typedef void (^DispatchRepeatCompletionHandler)(BOOL repeat);
typedef void (^DispatchRepeatBlock)(DispatchRepeatCompletionHandler completionHandler);
@interface KVMThunderboltObserver ()

@property BOOL initialized;
@property BOOL macConnected;
@property NSArray *systemProfilerInformation;
@property (nonatomic, copy) DispatchRepeatBlock repeatBlock;
@property (nonatomic, assign) BOOL shouldRepeat;

@end


@implementation KVMThunderboltObserver

#pragma mark - Public Interface

- (id)initWithDelegate:(id<KVMThunderBoltObserverDelegate>)delegate {
  self = [super init];
  self.delegate = delegate;
  self.macConnected = NO;
  self.systemProfilerInformation = nil;

  return self;
}

- (void)startObserving {
    if (!self.repeatBlock) {
       [self registerRepeatBlock];
    }
}

- (void)registerRepeatBlock {
    
    __weak typeof(self) weakSelf = self;
    self.shouldRepeat = YES;
    self.repeatBlock = ^(DispatchRepeatCompletionHandler completionHandler) {
        typeof(self) strongSelf = weakSelf;
        [strongSelf checkForThunderboltConnection];
        completionHandler(strongSelf.shouldRepeat);
    };
    
    [self dispatchRepeatWithTimeInterval:kTimeInterval completionHandler:self.repeatBlock];
}
- (void)stopObserving {
    self.shouldRepeat = NO;
    self.repeatBlock = nil;
}

#pragma mark - Private Interface

- (void)dispatchRepeatWithTimeInterval:(NSTimeInterval)interval completionHandler:(DispatchRepeatBlock)completionHandler {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completionHandler(^(BOOL repeat) {
            if (repeat) {
            return [self dispatchRepeatWithTimeInterval:interval completionHandler:completionHandler];
            }
        });
    });
    
}

- (void)updateSystemProfilerInformation {
  self.systemProfilerInformation = [KVMSystemProfiler dataTypes:@[@"SPDisplaysDataType", @"SPThunderboltDataType"]];
}

- (NSDictionary *)systemProfilerDisplayInfo {
  if (self.systemProfilerInformation == nil) {
    [self updateSystemProfilerInformation];
  }
  
  return self.systemProfilerInformation[0];
}

- (NSDictionary *)systemProfilerThunderboltInfo {
  if (self.systemProfilerInformation == nil) {
    [self updateSystemProfilerInformation];
  }
  
  return self.systemProfilerInformation[1];
}

- (void)checkForThunderboltConnection {
  [self updateSystemProfilerInformation];
  
  BOOL previouslyConnected = self.macConnected;
  self.macConnected = [self macConnectedViaThunderbolt] || [self macConnectedViaDisplayPort];
  BOOL changed = self.macConnected != previouslyConnected;

  if (changed) {
    [self notifyDelegateOfConnectionChange];
  }

  if (!self.initialized) {
    self.initialized = YES;
    [self notifyDelegateOfInitialization];
  }
}

- (void)notifyDelegateOfConnectionChange {
  if (self.macConnected) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(thunderboltObserverDeviceConnected:)]) {
      [self.delegate thunderboltObserverDeviceConnected:self];
    }
  } else {
    if (self.delegate && [self.delegate respondsToSelector:@selector(thunderboltObserverDeviceDisconnected:)]) {
      [self.delegate thunderboltObserverDeviceDisconnected:self];
    }
  }
}

- (void)notifyDelegateOfInitialization {
  if (self.delegate && [self.delegate respondsToSelector:@selector(thunderboltObserver:isInitiallyConnected:)]) {
    [self.delegate thunderboltObserver:self isInitiallyConnected:self.macConnected];
  }
}

- (BOOL)macConnectedViaDisplayPort {
  if ([self isInTargetDisplayMode]) {
    return YES;
  }

  NSDictionary *plist = [self systemProfilerDisplayInfo];

  NSArray *gpus = plist[@"_items"];

  for (NSDictionary *gpu in gpus) {
    NSArray *displays = gpu[@"spdisplays_ndrvs"];

    for (NSDictionary *display in displays) {
      if ([display[@"spdisplays_connection_type"] isEqualToString:@"spdisplays_displayport_dongletype_dp"]) {
        if ([display[@"_spdisplays_display-vendor-id"] isEqualToString:@"610"]) {
          return YES;
        }
      }
    }
  }

  return NO;
}

- (BOOL)isInTargetDisplayMode {
  NSDictionary *plist = [self systemProfilerDisplayInfo];

  NSArray *gpus = plist[@"_items"];

  for (NSDictionary *gpu in gpus) {
    NSArray *displays = gpu[@"spdisplays_ndrvs"];

    for (NSDictionary *display in displays) {
      if ([display[@"_name"] isEqualToString:@"iMac"] && [display[@"spdisplays_builtin"] isEqualToString:@"spdisplays_yes"]) {
        if (display[@"_spdisplays_displayport_device"] == nil) {
          return YES;
        }
      }
    }
  }

  return NO;
}

- (BOOL)macConnectedViaThunderbolt {
  NSDictionary *plist = [self systemProfilerThunderboltInfo];

  NSArray *devices = plist[@"_items"][0][@"_items"];

  for (NSDictionary *device in devices) {
    if ([device[@"vendor_id_key"] isEqualToString:@"0xA27"]) {
      return YES;
    }
  }

  return NO;
}

@end
