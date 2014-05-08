#import <Foundation/Foundation.h>

@protocol KVMThunderBoltObserverDelegate;

@interface KVMThunderboltObserver : NSObject
@property (nonatomic, assign) id<KVMThunderBoltObserverDelegate> delegate;
@property (readonly) BOOL macConnected;

- (id)initWithDelegate:(id<KVMThunderBoltObserverDelegate>)delegate;
- (void)startObserving;
- (void)stopObserving;

@end

@protocol KVMThunderBoltObserverDelegate <NSObject>

@optional
- (void)thunderboltObserverDeviceConnected:(KVMThunderboltObserver *)observer;
- (void)thunderboltObserverDeviceDisconnected:(KVMThunderboltObserver *)observer;

@end