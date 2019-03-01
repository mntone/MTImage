#ifndef MTImageSource_h
#define MTImageSource_h

typedef struct _MTImageSource MTImageSource;
typedef MTImageSource * MTImageSourceRef;

CF_ASSUME_NONNULL_BEGIN

extern const CFStringRef __nonnull kUTTypeWebP;
extern const CFStringRef __nonnull kCGImagePropertyWebPDictionary;
extern const CFStringRef __nonnull kCGImagePropertyWebPLoopCount;
extern const CFStringRef __nonnull kCGImagePropertyWebPDuration;

extern MTImageSourceRef __nullable MTImageSourceCreateWithData(CFDataRef data, CFDictionaryRef __nullable options) CF_RETURNS_RETAINED API_AVAILABLE(macos(10.4), ios(4.0));

extern void MTImageSourceRelease(MTImageSourceRef isrc) API_AVAILABLE(macos(10.4), ios(4.0));

extern CFStringRef __nullable MTImageSourceGetType(MTImageSourceRef isrc) API_AVAILABLE(macos(10.4), ios(4.0));

extern size_t MTImageSourceGetCount(MTImageSourceRef isrc) API_AVAILABLE(macos(10.4), ios(4.0));

extern CFDictionaryRef __nullable MTImageSourceCopyPropertiesAtIndex(MTImageSourceRef isrc, size_t index, CFDictionaryRef __nullable options) CF_RETURNS_RETAINED API_AVAILABLE(macos(10.4), ios(4.0));

extern CGImageRef __nullable MTImageSourceCreateImageAtIndex(MTImageSourceRef isrc, size_t index, CFDictionaryRef __nullable options) CF_RETURNS_RETAINED API_AVAILABLE(macos(10.4), ios(4.0));

CF_ASSUME_NONNULL_END

#endif /* MTImageSource_h */
