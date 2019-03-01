#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MTAnimatedImageViewAnimationControllerProtocol <NSObject>

- (nullable instancetype)initWithView:(MTAnimatedImageView *)view;

- (void)reset;
- (void)invalidate;

@end

@interface MTAnimatedImageViewAnimationController : NSObject <MTAnimatedImageViewAnimationControllerProtocol>

- (nullable instancetype)initWithView:(MTAnimatedImageView *)view;

- (void)reset;
- (void)invalidate;
#if TARGET_OS_IPHONE
- (void)displayLinkDidFire:(CADisplayLink *)sender;
#else
- (void)displayLinkDidFire:(CVDisplayLinkRef)sender inOutputTime:(const CVTimeStamp *)outputTime;
#endif
- (NSNumber *)delayTimeAtIndex:(NSInteger)index;

@property (nonatomic, readonly, weak) MTAnimatedImageView *view;
@property (nonatomic) NSInteger frameCount;
@property (nonatomic) NSInteger loopCount;

@end

@interface MTAnimatedImageViewAnimationControllerGifA : MTAnimatedImageViewAnimationController
@end

NS_CLASS_AVAILABLE(10.10, 8.0) @interface MTAnimatedImageViewAnimationControllerAPNG : MTAnimatedImageViewAnimationController
@end

@interface MTAnimatedImageViewAnimationControllerWebP : MTAnimatedImageViewAnimationController
@end

NS_ASSUME_NONNULL_END
