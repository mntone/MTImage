#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif
#import "MTAnimatedImage+Internal.h"
#import "MTAnimatedImageView+Internal.h"
#import "MTAnimatedImageViewAnimationController.h"

#if !TARGET_OS_IPHONE
static CVReturn renderCallback(CVDisplayLinkRef displayLink,
							   const CVTimeStamp *inNow,
							   const CVTimeStamp *inOutputTime,
							   CVOptionFlags flagsIn,
							   CVOptionFlags *flagsOut,
							   void *displayLinkContext) {
	MTAnimatedImageViewAnimationController *animationController = (__bridge MTAnimatedImageViewAnimationController *)displayLinkContext;
	[animationController displayLinkDidFire:displayLink inOutputTime:inOutputTime];
	return kCVReturnSuccess;
}
#endif

@interface MTAnimatedImageViewAnimationController()

- (NSDictionary *)propertiesAtIndex:(NSInteger)index withTarget:(CFStringRef)target;

@end

@implementation MTAnimatedImageViewAnimationController
{
	CFTimeInterval _elapsedTime;
	CFTimeInterval _previousTime;
	NSInteger _remainingLoopCount;
	
#if TARGET_OS_IPHONE
	CADisplayLink *_displayLink;
#else
	CVDisplayLinkRef _displayLink;
#endif
}

- (instancetype)initWithView:(MTAnimatedImageView *)view
{
	if (!view) {
		return nil;
	}
	
	if (self = [super init]) {
		_elapsedTime = 0.0;
		_previousTime = 0.0;
		_frameCount = 0;
		_loopCount = 0;
		_remainingLoopCount = 0;
		
		_view = view;
		[self reset];
		
#if TARGET_OS_IPHONE
		CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
		[displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
		_displayLink = displayLink;
#else
		NSNumber *currentDisplayId = [_view.window.screen.deviceDescription objectForKey:@"NSDisplayID"];
		CGDirectDisplayID displayId = (CGDirectDisplayID)[currentDisplayId integerValue];
		if (CVDisplayLinkCreateWithCGDisplay(displayId, &_displayLink) == kCVReturnSuccess) {
			CVDisplayLinkSetOutputCallback(_displayLink, renderCallback, (__bridge void *)self);
			CVDisplayLinkStart(_displayLink);
		}
#endif
	}
	return self;
}

- (void)dealloc
{
	[self invalidate];
}

- (void)reset
{
	[_view setAnimating:YES];
	_elapsedTime = 0.0;
	_previousTime = 0.0;
}

- (void)invalidate
{
	[_view setAnimating:NO];
	if (_displayLink) {
#if TARGET_OS_IPHONE
		[_displayLink invalidate];
#else
		CVDisplayLinkStop(_displayLink);
#endif
	}
}

#if TARGET_OS_IPHONE
- (void)displayLinkDidFire:(CADisplayLink *)sender
#else
- (void)displayLinkDidFire:(CVDisplayLinkRef)sender inOutputTime:(const CVTimeStamp *)outputTime
#endif
{
	MTAnimatedImage *image = _view.image;
	if (!image) {
		return;
	}
	
	NSInteger displayedIndex = _view.displayedIndex;
	NSNumber *nsDelayTime = [self delayTimeAtIndex:displayedIndex];
	double delayTime = nsDelayTime.doubleValue;
	
#if TARGET_OS_IPHONE
	CFTimeInterval timestamp = sender.timestamp;
#else
	CFTimeInterval timestamp = (double)outputTime->videoTime / outputTime->videoTimeScale;
#endif
	_elapsedTime += timestamp - _previousTime;
	_previousTime = timestamp;
	
	if (_elapsedTime >= MAX(10.0, delayTime + 10.0)) {
		_elapsedTime = 0.0;
	}
	
	while (_elapsedTime >= delayTime) {
		_elapsedTime -= delayTime;
		++displayedIndex;
		
		if (displayedIndex >= _frameCount) {
			if (_loopCount == 0) {
				displayedIndex = 0;
			} else {
				--_remainingLoopCount;
				if (_remainingLoopCount == 0) {
					[self invalidate];
				} else {
					displayedIndex = 0;
				}
			}
		}
	}

#if TARGET_OS_IPHONE
	[_view setDisplayedIndex:displayedIndex];
#else
	if (displayedIndex != _view.displayedIndex) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self->_view setDisplayedIndex:displayedIndex];
		});
	}
#endif
}

- (void)setLoopCount:(NSInteger)loopCount
{
	_loopCount = loopCount;
	_remainingLoopCount = loopCount;
}

- (NSNumber *)delayTimeAtIndex:(NSInteger)index
{
	NSAssert(NO, @"Subclasses must implement delayTimeAtIndex(index:)");
	return nil;
}

- (NSDictionary *)propertiesAtIndex:(NSInteger)index withTarget:(CFStringRef)target
{
	MTAnimatedImage *image = _view.image;
	if (!image) {
		return nil;
	}
	
	CFDictionaryRef properties = [image propertiesAtIndex:index];
	if (!properties) {
		return nil;
	}
	
	CFDictionaryRef targetProperties = CFDictionaryGetValue(properties, target);
	return (__bridge_transfer NSDictionary *)targetProperties;
}

@end

@implementation MTAnimatedImageViewAnimationControllerGifA

- (void)reset
{
	[super reset];
	
	MTAnimatedImage *image = self.view.image;
	if (image) {
		[self setFrameCount:image.count];
	} else {
		[self setFrameCount:0];
	}
	
	NSDictionary *gifProperties = [self propertiesAtIndex:0 withTarget:kCGImagePropertyGIFDictionary];
	if (gifProperties) {
		NSInteger loopCount = [[gifProperties objectForKey:(__bridge id)kCGImagePropertyGIFLoopCount] integerValue];
		[self setLoopCount:loopCount];
		return;
	}
	[self setLoopCount:0];
}

- (NSNumber *)delayTimeAtIndex:(NSInteger)index
{
	NSDictionary *gifProperties = [self propertiesAtIndex:index withTarget:kCGImagePropertyGIFDictionary];
	if (!gifProperties) {
		return nil;
	}
	
	if (@available(macOS 10.7, *)) {
		NSNumber *unclampedDelayTime = [gifProperties objectForKey:(__bridge id)kCGImagePropertyGIFUnclampedDelayTime];
		if (unclampedDelayTime) {
			return unclampedDelayTime;
		}
	}
	
	NSNumber *delayTime = [gifProperties objectForKey:(__bridge id)kCGImagePropertyGIFDelayTime];
	return delayTime;
}

@end

@implementation MTAnimatedImageViewAnimationControllerAPNG

- (void)reset
{
	[super reset];
	
	MTAnimatedImage *image = self.view.image;
	if (image) {
		[self setFrameCount:image.count];
	} else {
		[self setFrameCount:0];
	}
	
	NSDictionary *pngProperties = [self propertiesAtIndex:0 withTarget:kCGImagePropertyPNGDictionary];
	if (pngProperties) {
		NSInteger loopCount = [[pngProperties objectForKey:(__bridge id)kCGImagePropertyAPNGLoopCount] integerValue];
		[self setLoopCount:loopCount];
		return;
	}
	[self setLoopCount:0];
}

- (NSNumber *)delayTimeAtIndex:(NSInteger)index
{
	NSDictionary *pngProperties = [self propertiesAtIndex:index withTarget:kCGImagePropertyPNGDictionary];
	if (!pngProperties) {
		return nil;
	}
	
	NSNumber *unclampedDelayTime = [pngProperties objectForKey:(__bridge id)kCGImagePropertyAPNGUnclampedDelayTime];
	if (unclampedDelayTime) {
		return unclampedDelayTime;
	}
	
	NSNumber *delayTime = [pngProperties objectForKey:(__bridge id)kCGImagePropertyAPNGDelayTime];
	return delayTime;
}

@end

@implementation MTAnimatedImageViewAnimationControllerWebP

- (void)reset
{
	[super reset];
	
	MTAnimatedImage *image = self.view.image;
	if (image) {
		[self setFrameCount:image.count];
	} else {
		[self setFrameCount:0];
	}
	
	NSDictionary *webpProperties = [self propertiesAtIndex:0 withTarget:kCGImagePropertyWebPDictionary];
	if (webpProperties) {
		NSInteger loopCount = [[webpProperties objectForKey:(__bridge id)kCGImagePropertyWebPLoopCount] integerValue];
		[self setLoopCount:loopCount];
		return;
	}
	[self setLoopCount:0];
}

- (NSNumber *)delayTimeAtIndex:(NSInteger)index
{
	NSDictionary *webpProperties = [self propertiesAtIndex:index withTarget:kCGImagePropertyWebPDictionary];
	if (!webpProperties) {
		return nil;
	}
	
	NSNumber *delayTime = [webpProperties objectForKey:(__bridge id)kCGImagePropertyWebPDuration];
	return delayTime;
}

@end
