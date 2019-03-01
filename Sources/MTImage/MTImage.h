#import <Foundation/Foundation.h>
#import "MTImageSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTImage : NSObject

- (nullable instancetype)initWithData:(NSData *)data;

@property (nullable, nonatomic, readonly) CGImageRef CGImage;

@end

NS_ASSUME_NONNULL_END
