#import "MTAnimatedImage.h"

NS_ASSUME_NONNULL_BEGIN

#if TARGET_OS_IPHONE
NS_CLASS_AVAILABLE_IOS(3_1) @interface MTAnimatedImageView : UIView

- (instancetype)initWithImage:(nullable MTAnimatedImage *)image;
#else
@interface MTAnimatedImageView : NSView
#endif

@property (nullable, nonatomic, strong) MTAnimatedImage *image; // default is nil

#if !TARGET_OS_IPHONE
@property NSImageAlignment imageAlignment;
@property NSImageScaling imageScaling;
#endif

- (void)updateAnimation;

@property (nonatomic, readonly, getter=isAnimating) BOOL animating;

@end

#if !TARGET_OS_IPHONE
@interface MTAnimatedImageView(MTAnimatedImageViewConvenience)

+ (instancetype)imageViewWithImage:(nullable MTAnimatedImage *)image;

@end
#endif

NS_ASSUME_NONNULL_END
