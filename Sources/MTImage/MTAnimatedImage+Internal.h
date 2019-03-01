#import "MTAnimatedImage.h"

@interface MTAnimatedImage()

- (CGImageRef)cgImageAtIndex:(NSInteger)index;
- (CFDictionaryRef)propertiesAtIndex:(NSInteger)index;

@property (nonatomic, readonly) CFStringRef type;
@property (nonatomic, readonly) NSInteger count;

@end
