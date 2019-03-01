#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif
#import "MTImageView.h"

@implementation MTImageView
{
	bool _shown;
}

#if TARGET_OS_IPHONE
- (instancetype)initWithImage:(MTImage *)image
{
	if (self = [super init]) {
		_shown = false;
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

- (instancetype)imageViewWithImage:(MTImage *)image
{
	MTImageView *that = [[MTImageView alloc] init];
	if (that) {
		[that setImage:image];
	}
	return that;
}

- (void)commonInit
{
	_shown = false;
	self.wantsLayer = YES;
	self.layer.contentsGravity = kCAGravityResize;
}
#endif

- (void)setImage:(MTImage *)image
{
	_shown = false;
	_image = image;
	[self updateImage];
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
	[self updateImage];
}

#if TARGET_OS_IPHONE
- (void)setAlpha:(CGFloat)alpha
{
	[super setAlpha:alpha];
	[self updateImage];
}

- (void)didMoveToWindow
{
	[super didMoveToWindow];
	[self updateImage];
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	[self updateImage];
}
#else
- (void)setAlphaValue:(CGFloat)alphaValue
{
	[super setAlphaValue:alphaValue];
	[self updateImage];
}

- (void)viewDidMoveToWindow
{
	[super viewDidMoveToWindow];
	[self updateImage];
}

- (void)viewDidMoveToSuperview
{
	[super viewDidMoveToSuperview];
	[self updateImage];
}
#endif

- (void)updateImage
{
#if TARGET_OS_IPHONE
	BOOL appeared = self.window != nil && self.superview != nil && self.alpha > 0.0;
#else
	BOOL appeared = self.window != nil && self.superview != nil && self.alphaValue > 0.0;
#endif
	if (appeared && !_shown) {
		_shown = true;
		self.layer.contents = (__bridge id _Nullable)_image.CGImage;
	}
}

@end
