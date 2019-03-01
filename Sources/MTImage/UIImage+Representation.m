#import <AVFoundation/AVMediaFormat.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <webp/types.h>
#include <webp/encode.h>
#include <webp/mux.h>
#import "UIImage+Representation.h"

NSData *UIImageHEICRepresentation(UIImage *image, CGFloat compressionQuality) {
	if (!image) {
		return NULL;
	}
	
	CGImageRef cgImage = image.CGImage;
	if (!cgImage) {
		return NULL;
	}
	
	CFMutableDataRef data = CFDataCreateMutable(NULL, 0);
	CGImageDestinationRef dest = CGImageDestinationCreateWithData(data, (__bridge CFStringRef)AVFileTypeHEIC, 1, NULL);
	if (dest) {
		NSDictionary *options = @{(__bridge NSString *)kCGImageDestinationLossyCompressionQuality: @(compressionQuality)};
		CGImageDestinationAddImage(dest, cgImage, (__bridge CFDictionaryRef)options);
		CGImageDestinationFinalize(dest);
		CFRelease(data);
		return (__bridge_transfer NSData *)data;
	}
	return NULL;
}

NSData *UIImageWebPRepresentation(UIImage *image, CGFloat compressionQuality) {
	if (!image) {
		return NULL;
	}
	
	CGImageRef cgImage = image.CGImage;
	if (!cgImage) {
		return NULL;
	}
	
	CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
	if (!provider) {
		return NULL;
	}
	
	CFDataRef result = NULL;
	CFDataRef data = CGDataProviderCopyData(provider);
	if (data) {
		WebPConfig config;
		if (WebPConfigPreset(&config, WEBP_PRESET_DEFAULT, 100.0F * (float)compressionQuality) != 0) {
			if (compressionQuality >= 1.0) {
				config.lossless = 1;
			}
			
			WebPPicture picture;
			if (WebPPictureInit(&picture) != 0) {
				picture.use_argb = config.lossless;
				picture.width = (int)CGImageGetWidth(cgImage);
				picture.height = (int)CGImageGetHeight(cgImage);
				
				const int stride = (int)CGImageGetBytesPerRow(cgImage);
				const uint8_t *ptr = CFDataGetBytePtr(data);
				CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
				CGBitmapInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
				if (alphaInfo == kCGImageAlphaLast || alphaInfo == kCGImageAlphaPremultipliedLast) {
					WebPPictureImportRGBA(&picture, ptr, stride);
				} else if (alphaInfo == kCGImageAlphaNoneSkipLast) {
					WebPPictureImportRGBX(&picture, ptr, stride);
				} else if (alphaInfo == kCGImageAlphaNone) {
					WebPPictureImportRGB(&picture, ptr, stride);
				} else {
					goto finally;
				}
				
				WebPMemoryWriter writer;
				WebPMemoryWriterInit(&writer);
				picture.writer = WebPMemoryWrite;
				picture.custom_ptr = &writer;
				
				if (WebPEncode(&config, &picture) != 0) {
					WebPMux *mux = WebPMuxNew();
					if (mux) {
						WebPData frameData = { writer.mem, writer.size };
						WebPMuxSetImage(mux, &frameData, 0);
						
						CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
						if (colorSpace) {
							CFDataRef iccProfile = NULL;
							if (@available(iOS 10.0, tvOS 10.0, *)) {
								iccProfile = CGColorSpaceCopyICCData(colorSpace);
							} else {
								iccProfile = CGColorSpaceCopyICCProfile(colorSpace);
							}
							if (iccProfile) {
								const void *iccProfileData = CFDataGetBytePtr(iccProfile);
								const size_t iccProfileSize = CFDataGetLength(iccProfile);
								WebPMuxSetChunk(mux, "ICCP", iccProfileData, (int)iccProfileSize);
								CFRelease(iccProfile);
							}
						}
						
						WebPData outputData = { 0 };
						WebPMuxAssemble(mux, &outputData);
						WebPMuxDelete(mux);
						
						result = CFDataCreate(NULL, outputData.bytes, outputData.size);
						
						WebPDataClear(&outputData);
					}
				}
				WebPMemoryWriterClear(&writer);
finally:
				WebPPictureFree(&picture);
			}
		}
		CFRelease(data);
	}
	return (__bridge_transfer NSData * _Nullable)result;
}
