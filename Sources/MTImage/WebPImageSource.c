#include <ImageIO/ImageIO.h>
#include <webp/types.h>
#include <webp/demux.h>
#include "webpdec.h"
#include "WebPImageSource.h"

CGImageRef MTWebPImageCreateWithData(CFDataRef data, CFDictionaryRef options) {
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
	if (!demuxer) {
		return NULL;
	}
	
	CGColorSpaceRef colorSpace = WebPGetColorSpace(demuxer);
	
	const UInt32 pixelWidth = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH);
	const UInt32 pixelHeight = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT);
	
	CGImageRef image = NULL;
	WebPIterator itr;
	if (WebPDemuxGetFrame(demuxer, 1, &itr)) {
		image = WebPCGImageCreate(NULL, pixelWidth, pixelHeight, &itr, colorSpace);
		WebPDemuxReleaseIterator(&itr);
	}
	WebPDemuxDelete(demuxer);
	
	if (colorSpace) {
		CGColorSpaceRelease(colorSpace);
	}
	
	return image;
}
