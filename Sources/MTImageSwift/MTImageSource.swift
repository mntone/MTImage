import MTImage.MTImageSource

public final class MTImageSource {
	private let imageSource: MTImageSourceRef
	
	public init?(data: Data, options: MTImageSourceCreateOption? = nil) {
		guard let imageSource = MTImageSourceCreateWithData(data as CFData, options?.get()) else { return nil }
		
		self.imageSource = imageSource
	}
	
	deinit {
		MTImageSourceRelease(imageSource)
	}
	
	public subscript(_ index: Int) -> CGImage? {
		return MTImageSourceCreateImageAtIndex(imageSource, index, nil)
	}
	
	public func cgImage(at index: Int, options: MTImageCreateOption? = nil) -> CGImage? {
		return MTImageSourceCreateImageAtIndex(imageSource, index, options?.get())
	}
	
	public func properties(at index: Int, options: MTImageCreateOption? = nil) -> NSDictionary? {
		return MTImageSourceCopyPropertiesAtIndex(imageSource, index, options?.get())
	}
}
