#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import <webp/types.h>
#import <webp/demux.h>
#include "webpdec.h"

enum MTImageType {
	kCoreGraphicsImageType = 0,
	kWebPImageType = 1,
};

struct _MTImageSource {
	enum MTImageType type;
	union {
		struct {
			CGImageSourceRef cgImageSource;
		} cg;
		struct {
			WebPDemuxer *demuxer;
			size_t width;
			size_t height;
			size_t loopCount;
			size_t frameCount;
			CGImageRef *images;
			CGColorSpaceRef colorSpace;
		} webp;
	};
};

#import "MTImageSource.h"

const CFStringRef kUTTypeWebP = CFSTR("public.webp");
const CFStringRef kCGImagePropertyWebPDictionary = CFSTR("{WebP}");
const CFStringRef kCGImagePropertyWebPLoopCount = CFSTR("LoopCount");
const CFStringRef kCGImagePropertyWebPDuration = CFSTR("Duration");

MTImageSourceRef MTImageSourceCreateWithData(CFDataRef data, CFDictionaryRef options) {
	const CFIndex length = CFDataGetLength(data);
	if (length <= 0) {
		return NULL;
	}
	
	const UInt8 *ptr = CFDataGetBytePtr(data);
	if (!ptr) {
		return NULL;
	}
	
	WebPData webpData = { ptr, length };
	WebPDemuxer *demuxer = WebPDemux(&webpData);
	if (demuxer) {
		MTImageSourceRef imageSource = (MTImageSourceRef)malloc(sizeof(MTImageSource));
		if (!imageSource) {
			return NULL;
		}
		memset(imageSource, 0, sizeof(MTImageSource));
		
		const UInt32 width = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH);
		const UInt32 height = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT);
		const UInt32 loopCount = WebPDemuxGetI(demuxer, WEBP_FF_LOOP_COUNT);
		const UInt32 frameCount = WebPDemuxGetI(demuxer, WEBP_FF_FRAME_COUNT);
		
		imageSource->type = kWebPImageType;
		imageSource->webp.demuxer = demuxer;
		imageSource->webp.width = width;
		imageSource->webp.height = height;
		imageSource->webp.loopCount = loopCount;
		imageSource->webp.frameCount = frameCount;
		
		size_t imagesSize = frameCount * sizeof(CGImageRef);
		CGImageRef *images = (CGImageRef *)malloc(imagesSize);
		if (!images) {
			return NULL;
		}
		memset(images, 0, imagesSize);
		
		imageSource->webp.images = images;
		imageSource->webp.colorSpace = NULL;
		return imageSource;
	} else {
		CGImageSourceRef cgImageSource = CGImageSourceCreateWithData(data, options);
		if (!cgImageSource) {
			return NULL;
		}
		
		MTImageSourceRef imageSource = (MTImageSourceRef)malloc(sizeof(MTImageSourceRef));
		if (!imageSource) {
			CFRelease(cgImageSource);
			return NULL;
		}
		memset(imageSource, 0, sizeof(MTImageSource));
		
		imageSource->type = kCoreGraphicsImageType;
		CFRetain(cgImageSource);
		imageSource->cg.cgImageSource = cgImageSource;
		return imageSource;
	}
}

void MTImageSourceRelease(MTImageSourceRef isrc) {
	if (isrc->type == kWebPImageType) {
		WebPDemuxDelete(isrc->webp.demuxer);
		if (isrc->webp.colorSpace) {
			CGColorSpaceRelease(isrc->webp.colorSpace);
		}
		if (isrc->webp.images) {
			isrc->webp.images = NULL;
		}
		free(isrc->webp.images);
	} else {
		CFRelease(isrc->cg.cgImageSource);
	}
	free(isrc);
}

CFStringRef MTImageSourceGetType(MTImageSourceRef isrc) {
	if (isrc->type == kWebPImageType) {
		return kUTTypeWebP;
	} else {
		return CGImageSourceGetType(isrc->cg.cgImageSource);
	}
}

size_t MTImageSourceGetCount(MTImageSourceRef isrc) {
	if (isrc->type == kWebPImageType) {
		return isrc->webp.frameCount;
	} else {
		return CGImageSourceGetCount(isrc->cg.cgImageSource);
	}
}

CFDictionaryRef MTImageSourceCopyPropertiesAtIndex(MTImageSourceRef isrc, size_t index, CFDictionaryRef options) {
	if (isrc->type == kWebPImageType) {
		WebPIterator itr;
		if (WebPDemuxGetFrame(isrc->webp.demuxer, (int)(index + 1), &itr)) {
			NSDictionary *properties = @{
				(__bridge NSString *)kCGImagePropertyPixelWidth: @(isrc->webp.width),
				(__bridge NSString *)kCGImagePropertyPixelHeight: @(isrc->webp.height),
				(__bridge NSString *)kCGImagePropertyDepth: @8,
				(__bridge NSString *)kCGImagePropertyColorModel: (__bridge NSString *)kCGImagePropertyColorModelRGB,
				(__bridge NSString *)kCGImagePropertyWebPDictionary: @{
					(__bridge NSString *)kCGImagePropertyWebPLoopCount: @(isrc->webp.loopCount),
					(__bridge NSString *)kCGImagePropertyWebPDuration: @((double)itr.duration / 1000.0),
				}
			};
			WebPDemuxReleaseIterator(&itr);
			return (__bridge_retained CFDictionaryRef)properties;
		}
		return NULL;
	} else {
		return CGImageSourceCopyPropertiesAtIndex(isrc->cg.cgImageSource, index, options);
	}
}

CGImageRef MTImageSourceCreateImageAtIndex(MTImageSourceRef isrc, size_t index, CFDictionaryRef options) {
	if (isrc->type == kWebPImageType) {
		if (!isrc->webp.colorSpace) {
			isrc->webp.colorSpace = WebPGetColorSpace(isrc->webp.demuxer);
		}
		
		CGImageRef image = isrc->webp.images[index];//(__bridge_retained CGImageRef)([isrc->webp.images objectForKey:@(index)]);
		if (image) {
			CFRetain(image);
			return image;
		}
		
		WebPIterator itr;
		if (!WebPDemuxGetFrame(isrc->webp.demuxer, (int)(index + 1), &itr)) {
			return NULL;
		}
		
		CGImageRef refImage = nil;
		if (itr.dispose_method == WEBP_MUX_BLEND && index > 0) {
			refImage = isrc->webp.images[index - 1]; //(__bridge_retained CGImageRef)([isrc->webp.images objectForKey:@(index)]);
		}
		
		image = WebPCGImageCreate(refImage, isrc->webp.width, isrc->webp.height, &itr, isrc->webp.colorSpace);
		if (image) {
			CFRetain(image);
			isrc->webp.images[index] = image;
			//[isrc->webp.images setObject:(__bridge id _Nonnull)(image) forKey:@(index)];
		}
		WebPDemuxReleaseIterator(&itr);
		return image;
	} else {
		CGImageSourceRef imageSource = isrc->cg.cgImageSource;
		return CGImageSourceCreateImageAtIndex(imageSource, index, options);
	}
}
