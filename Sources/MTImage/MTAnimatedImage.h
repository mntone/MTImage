#import <Foundation/Foundation.h>
#import "MTImageSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTAnimatedImage : NSObject

- (instancetype)initWithImageSource:(MTImageSource *)imageSource;

- (nullable instancetype)initWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
