#ifndef webpdec_h
#define webpdec_h

extern CGColorSpaceRef WebPGetColorSpace(WebPDemuxer *demuxer);

extern CGImageRef WebPCGImageCreate(CGImageRef refImage, size_t width, size_t height, WebPIterator *iterator, CGColorSpaceRef colorSpace);

#endif /* webpdec_h */
