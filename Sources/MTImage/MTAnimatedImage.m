#import <ImageIO/ImageIO.h>
#import "MTImageSource.h"
#import "MTAnimatedImage+Internal.h"

@implementation MTAnimatedImage
{
	bool _owned;
	MTImageSource *_imageSource;
}

- (instancetype)initWithImageSource:(MTImageSource *)imageSource
{
	if (self = [super init]) {
		_owned = NO;
		_imageSource = imageSource;
	}
	return self;
}

- (instancetype)initWithData:(NSData *)data
{
	MTImageSourceRef imageSource = MTImageSourceCreateWithData((__bridge CFDataRef _Nonnull)(data), nil);
	if (!imageSource) {
		return nil;
	}
	
	if (self = [super init]) {
		_owned = YES;
		_imageSource = imageSource;
	}
	return self;
}

- (CFStringRef)type
{
	if (!_imageSource) {
		return nil;
	}
	
	return MTImageSourceGetType(_imageSource);
}

- (NSInteger)count
{
	if (!_imageSource) {
		return 0;
	}
	
	return MTImageSourceGetCount(_imageSource);
}

- (CGImageRef)cgImageAtIndex:(NSInteger)index
{
	if (!_imageSource) {
		return nil;
	}
	
	return MTImageSourceCreateImageAtIndex(_imageSource, index, nil);
}

- (CFDictionaryRef)propertiesAtIndex:(NSInteger)index
{
	if (!_imageSource) {
		return nil;
	}
	
	return MTImageSourceCopyPropertiesAtIndex(_imageSource, index, nil);
}

- (void)dealloc
{
	if (_owned) {
		MTImageSourceRelease(_imageSource);
		_imageSource = nil;
	}
}

@end
