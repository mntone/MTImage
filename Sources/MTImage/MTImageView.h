#import "MTImage.h"

NS_ASSUME_NONNULL_BEGIN

#if TARGET_OS_IPHONE
NS_CLASS_AVAILABLE_IOS(2_0) @interface MTImageView : UIView

- (instancetype)initWithImage:(nullable MTImage *)image;
#else
NS_CLASS_AVAILABLE_MAC(10_5) @interface MTImageView : NSView
#endif

@property (nullable, nonatomic, strong) MTImage *image; // default is nil

#if !TARGET_OS_IPHONE
@property NSImageAlignment imageAlignment;
@property NSImageScaling imageScaling;
#endif

@end

#if !TARGET_OS_IPHONE
@interface MTImageView(MTImageViewConvenience)

+ (instancetype)imageViewWithImage:(nullable MTImage *)image;

@end
#endif

NS_ASSUME_NONNULL_END
