#import <Foundation/Foundation.h>

@protocol KVMThunderBoltObserverDelegate;

@interface KVMThunderboltObserver : NSObject

@property (nonatomic, strong) id<KVMThunderBoltObserverDelegate> delegate;
@property (readonly) BOOL macConnected;

- (id)initWithDelegate:(id<KVMThunderBoltObserverDelegate>)delegate;
- (void)startObserving;
- (void)stopObserving;
- (BOOL)isInTargetDisplayMode;

@end

@protocol KVMThunderBoltObserverDelegate <NSObject>

@optional
- (void)thunderboltObserver:(KVMThunderboltObserver *)observer isInitiallyConnected:(BOOL)connected;
- (void)thunderboltObserverDeviceConnected:(KVMThunderboltObserver *)observer;
- (void)thunderboltObserverDeviceDisconnected:(KVMThunderboltObserver *)observer;

@end
