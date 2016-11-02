#import "KVMThunderboltObserver.h"

static NSTimeInterval const kTimeInterval = 2.0;

@interface KVMThunderboltObserver ()

@property (nonatomic, strong) NSTimer *timer;
@property BOOL initialized;
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
    
    if (!self.timer || ![self.timer isValid]) {
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
    
    if (! self.initialized) {
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


- (BOOL)macConnectedViaThunderbolt {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/sbin/system_profiler"];
    [task setArguments:@[@"SPThunderboltDataType", @"-xml"]];

    NSPipe *out = [NSPipe pipe];
    [task setStandardOutput:out];
    [task launch];

    NSFileHandle *read = [out fileHandleForReading];
    NSData *dataRead = [read readDataToEndOfFile];
    
    NSError *error;
    NSArray *plist = [NSPropertyListSerialization propertyListWithData:dataRead options:NSPropertyListImmutable format:NULL error:&error];
    NSArray *devices = plist[0][@"_items"][0][@"_items"];
    for (NSDictionary *device in devices) {
        if ([device[@"vendor_id_key"] isEqualToString:@"0xA27"]) {
            return YES;
        }
    }
    
    return NO;
}

@end
