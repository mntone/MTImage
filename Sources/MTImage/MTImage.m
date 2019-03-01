#import <ImageIO/ImageIO.h>
#import "MTImageSource.h"
#import "MTImage.h"
#import "WebPImageSource.h"

@implementation MTImage
{
	NSData *_data;
}

- (instancetype)initWithData:(NSData *)data
{
	if (!data) {
		return nil;
	}
	
	if (self = [super init]) {
		_data = data;
	}
	return self;
}

- (CGImageRef)CGImage
{
	CFDataRef data = (__bridge CFDataRef)_data;
	
	CGImageRef image = MTWebPImageCreateWithData(data, nil);
	if (!image) {
		CGImageSourceRef imageSource = CGImageSourceCreateWithData(data, nil);
		if (imageSource) {
#if __LP64__
			const CFTypeRef keys[] = { kCGImageSourceShouldCache, kCGImageSourceShouldAllowFloat };
			const CFTypeRef values[] = { kCFBooleanFalse, kCFBooleanTrue };
#else
			const CFTypeRef keys[] = { kCGImageSourceShouldAllowFloat };
			const CFTypeRef values[] = { kCFBooleanTrue };
#endif
			CFDictionaryRef options = CFDictionaryCreate(kCFAllocatorDefault,
														 (const void**)keys,
														 (const void**)values,
														 sizeof(keys) / sizeof(keys[0]),
														 &kCFTypeDictionaryKeyCallBacks,
														 &kCFTypeDictionaryValueCallBacks);
			image = CGImageSourceCreateImageAtIndex(imageSource, 0, options);
			CFRelease(imageSource);
		}
	}
	
	return image;
}

- (void)dealloc
{
	_data = nil;
}

@end
