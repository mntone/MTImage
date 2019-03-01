#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#else
#import <CoreServices/CoreServices.h>
#import <AppKit/AppKit.h>
#endif
#import "MTAnimatedImage+Internal.h"
#import "MTAnimatedImageView+Internal.h"
#import "MTAnimatedImageViewAnimationController.h"

@implementation MTAnimatedImageView
{
	MTAnimatedImageViewAnimationController *animationController;
}

#if TARGET_OS_IPHONE
- (instancetype)initWithImage:(MTAnimatedImage *)image
{
	if (self = [super init]) {
		[self setImage:image];
	}
	return self;
}
#else
- (instancetype)init
{
	if (self = [super init]) {
		[self commonInit];
	}
	return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect]) {
		[self commonInit];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
	if (self = [super initWithCoder:decoder]) {
		[self commonInit];
	}
	return self;
}

- (instancetype)initWithImage:(MTAnimatedImage *)image
{
	if (self = [super initWithFrame:CGRectZero]) {
		[self commonInit];
		[self setImage:image];
	}
	return self;
}

- (void)commonInit
{
	self.wantsLayer = YES;
	self.layer.contentsGravity = kCAGravityResize;
}
#endif

- (void)setImage:(MTAnimatedImage *)image
{
	[animationController invalidate];
	_displayedIndex = 0;
	_image = image;
	[self updateAnimation];
	[self updateImage];
}

- (void)setDisplayedIndex:(NSInteger)displayedIndex
{
	if (_displayedIndex != displayedIndex) {
		_displayedIndex = displayedIndex;
		[self updateImage];
	}
}

#if !TARGET_OS_IPHONE
- (NSImageAlignment)imageAlignment
{
	if ([kCAGravityTop isEqualToString:self.layer.contentsGravity]) {
		return NSImageAlignTop;
	}
	if ([kCAGravityTopLeft isEqualToString:self.layer.contentsGravity]) {
		return NSImageAlignTopLeft;
	}
	if ([kCAGravityTopRight isEqualToString:self.layer.contentsGravity]) {
		return NSImageAlignTopRight;
	}
	if ([kCAGravityLeft isEqualToString:self.layer.contentsGravity]) {
		return NSImageAlignLeft;
	}
	if ([kCAGravityBottom isEqualToString:self.layer.contentsGravity]) {
		return NSImageAlignBottom;
	}
	if ([kCAGravityBottomLeft isEqualToString:self.layer.contentsGravity]) {
		return NSImageAlignBottomLeft;
	}
	if ([kCAGravityBottomRight isEqualToString:self.layer.contentsGravity]) {
		return NSImageAlignBottomRight;
	}
	if ([kCAGravityRight isEqualToString:self.layer.contentsGravity]) {
		return NSImageAlignRight;
	}
	return NSImageAlignCenter;
}

- (void)setImageAlignment:(NSImageAlignment)imageAlignment
{
	switch (imageAlignment) {
		case NSImageAlignCenter:
			self.layer.contentsGravity = kCAGravityCenter;
			break;
			
		case NSImageAlignTop:
			self.layer.contentsGravity = kCAGravityTop;
			break;
			
		case NSImageAlignTopLeft:
			self.layer.contentsGravity = kCAGravityTopLeft;
			break;
			
		case NSImageAlignTopRight:
			self.layer.contentsGravity = kCAGravityTopRight;
			break;
			
		case NSImageAlignLeft:
			self.layer.contentsGravity = kCAGravityLeft;
			break;
			
		case NSImageAlignBottom:
			self.layer.contentsGravity = kCAGravityBottom;
			break;
			
		case NSImageAlignBottomLeft:
			self.layer.contentsGravity = kCAGravityBottomLeft;
			break;
			
		case NSImageAlignBottomRight:
			self.layer.contentsGravity = kCAGravityBottomRight;
			break;
			
		case NSImageAlignRight:
			self.layer.contentsGravity = kCAGravityRight;
			break;
	}
}

- (NSImageScaling)imageScaling
{
	if ([kCAGravityResize isEqualToString:self.layer.contentsGravity]) {
		return NSImageScaleAxesIndependently;
	}
	if ([kCAGravityResizeAspect isEqualToString:self.layer.contentsGravity]) {
		return NSImageScaleProportionallyUpOrDown;
	}
	return NSImageScaleNone;
}

- (void)setImageScaling:(NSImageScaling)imageScaling
{
	switch (imageScaling) {
		case NSImageScaleProportionallyDown:
			NSAssert(NO, @"NSImageScaleProportionallyDown is not supported enum.");
			break;
			
		case NSImageScaleAxesIndependently:
			self.layer.contentsGravity = kCAGravityResize;
			break;
			
		case NSImageScaleNone:
			self.layer.contentsGravity = kCAGravityTopLeft;
			break;
			
		case NSImageScaleProportionallyUpOrDown:
			self.layer.contentsGravity = kCAGravityResizeAspect;
			break;
	}
}
#endif

- (void)setHidden:(BOOL)hidden
{
	[super setHidden:hidden];
	[self updateAnimation];
}

#if TARGET_OS_IPHONE
- (void)setAlpha:(CGFloat)alpha
{
	[super setAlpha:alpha];
	[self updateAnimation];
}

- (void)didMoveToWindow
{
	[super didMoveToWindow];
	[self updateAnimation];
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	[self updateAnimation];
}
#else
- (void)setAlphaValue:(CGFloat)alphaValue
{
	[super setAlphaValue:alphaValue];
	[self updateAnimation];
}

- (void)viewDidMoveToWindow
{
	[super viewDidMoveToWindow];
	[self updateAnimation];
}

- (void)viewDidMoveToSuperview
{
	[super viewDidMoveToSuperview];
	[self updateAnimation];
}
#endif

- (void)updateImage
{
	self.layer.contents = (__bridge_transfer id _Nullable)[_image cgImageAtIndex:self.displayedIndex];
}

- (void)updateAnimation
{
	if (self.shouldAnimate) {
		CFStringRef type = _image.type;
		if (@available(iOS 4.0, macOS 10.4, *)) {
			if (CFEqual(type, kUTTypeGIF)) {
				animationController = [[MTAnimatedImageViewAnimationControllerGifA alloc] initWithView:self];
				return;
			}
		}
		if (@available(iOS 8.0, tvOS 8.0, macOS 10.10, *)) {
			if (CFEqual(type, kUTTypePNG)) {
				animationController = [[MTAnimatedImageViewAnimationControllerAPNG alloc] initWithView:self];
				return;
			}
		}
		if (CFEqual(type, kUTTypeWebP)) {
			animationController = [[MTAnimatedImageViewAnimationControllerWebP alloc] initWithView:self];
			return;
		}
		animationController = nil;
		return;
	} else {
		animationController = nil;
	}
}

- (BOOL)shouldAnimate
{
	if (!_image) {
		return NO;
	}
	
#if TARGET_OS_IPHONE
	BOOL shown = self.window != nil && self.superview != nil && self.alpha > 0.0;
#else
	BOOL shown = self.window != nil && self.superview != nil && self.alphaValue > 0.0;
#endif
	return shown && _image.count > 1;
}

@end
