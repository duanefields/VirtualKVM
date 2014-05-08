#import "KVMThunderboltObserver.h"

static NSTimeInterval const kTimeInterval = 2.0;

@interface KVMThunderboltObserver ()
@property NSTimer *timer;
@property BOOL macConnected;
@end


@implementation KVMThunderboltObserver

#pragma mark - Public Interface

- (id)initWithDelegate:(id<KVMThunderBoltObserverDelegate>)delegate {
    self = [super init];
    self.delegate = delegate;
    self.macConnected = NO;
    return self;
}

- (void)startObserving {
    if (![self.timer isValid]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimeInterval target:self selector:@selector(timerNotification:) userInfo:nil repeats:YES];
    }
}

- (void)stopObserving {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Private Interface

- (void)timerNotification:(NSNotification *)aNotification {
    BOOL previouslyConnected = self.macConnected;
    self.macConnected = [self macConnectedViaThunderbolt];
    BOOL changed = self.macConnected != previouslyConnected;
    if (changed) {
        [self notifyDelegateOfConnectionChange];
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

- (BOOL)macConnectedViaThunderbolt {
    const char *cmd = "/usr/sbin/system_profiler SPThunderboltDataType|/usr/bin/grep 0xA27";
    return system(cmd) == 0;
}

@end
