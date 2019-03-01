#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <webp/types.h>
#import <webp/demux.h>
#import "webpdec.h"

#define ALIGN16(size) (((size - 1) >> 4) << 4) + 16;

void bufferFree(void *info, const void *data, size_t size) {
	free((void *)data);
}

CGColorSpaceRef WebPGetColorSpace(WebPDemuxer *demuxer) {
	CGColorSpaceRef colorSpace = NULL;
	
	const UInt32 flags = WebPDemuxGetI(demuxer, WEBP_FF_FORMAT_FLAGS);
	if (flags & ICCP_FLAG) {
		WebPChunkIterator iccProfile;
		if (WebPDemuxGetChunk(demuxer, "ICCP", 1, &iccProfile)) {
			CFDataRef iccProfileData = CFDataCreateWithBytesNoCopy(NULL, iccProfile.chunk.bytes, iccProfile.chunk.size, NULL);
			if (iccProfileData) {
				if (@available(iOS 10.0, tvOS 10.0, macOS 10.12, *)) {
					colorSpace = CGColorSpaceCreateWithICCData(iccProfileData);
				} else {
					colorSpace = CGColorSpaceCreateWithICCProfile(iccProfileData);
				}
			}
		}
	}
	if (!colorSpace) {
		if (@available(iOS 9.0, tvOS 9.0, macOS 10.5, *)) {
			colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
		} else {
			colorSpace = CGColorSpaceCreateDeviceRGB();
		}
	}
	return colorSpace;
}

CGImageRef WebPCGImageCreate(CGImageRef refImage, size_t width, size_t height, WebPIterator *iterator, CGColorSpaceRef colorSpace) {
	WebPDecoderConfig config;
	if (!WebPInitDecoderConfig(&config)) {
		return NULL;
	}
	
	const size_t bytesPerPixel = 4;
	const size_t bytesPerRow = ALIGN16(bytesPerPixel * iterator->width);
	const size_t size = bytesPerRow * iterator->height;
	uint8_t *data = (uint8_t *)malloc(size);
	if (!data) {
		return NULL;
	}
	
	config.output.colorspace = MODE_bgrA;
	config.output.u.RGBA.rgba = data;
	config.output.u.RGBA.stride = (int)bytesPerRow;
	config.output.u.RGBA.size = size;
	config.output.is_external_memory = 1;
	if (WebPDecode(iterator->fragment.bytes, iterator->fragment.size, &config) != VP8_STATUS_OK) {
		return NULL;
	}
	
	const CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, size, bufferFree);
	CGImageRef image = CGImageCreate(iterator->width, iterator->height, 8, 8 * bytesPerPixel, bytesPerRow, colorSpace, bitmapInfo, provider, NULL, false, kCGRenderingIntentDefault);
	CGDataProviderRelease(provider);
	
	if (image && refImage) {
		CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8 * bytesPerPixel, 0, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
		if (context) {
			CGRect refRect = CGRectMake(0.0, 0.0, width, height);
			CGContextDrawImage(context, refRect, refImage);
			
			CGContextSetBlendMode(context, kCGBlendModeDestinationOver);
			
			CGRect overrideRect = CGRectMake(iterator->x_offset, iterator->y_offset, iterator->width, iterator->height);
			CGContextDrawImage(context, overrideRect, image);
			CGImageRelease(image);
			
			CGImageRef newImage = CGBitmapContextCreateImage(context);
			CGContextRelease(context);
			return newImage;
		}
	}
	
	return image;
}
